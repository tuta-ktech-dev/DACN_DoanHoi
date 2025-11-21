import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(
      event.studentId,
      event.password,
    );

    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.isAuthenticated();

    await result.fold(
      (failure) async {
        emit(const Unauthenticated());
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          final userResult = await _authRepository.getCurrentUser();
          await userResult.fold(
            (failure) async {
              emit(const Unauthenticated());
            },
            (user) async {
              emit(Authenticated(user));
            },
          );
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.refreshToken();

    result.fold(
      (failure) => emit(const Unauthenticated()),
      (token) {
        // Token refreshed successfully, stay authenticated
        if (state is Authenticated) {
          // Keep current authenticated state
        }
      },
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await _authRepository.register(
      fullName: event.fullName,
      username: event.username,
      email: event.email,
      password: event.password,
      studentId: event.studentId,
      phone: event.phone,
      dateOfBirth: event.dateOfBirth,
      gender: event.gender,
      faculty: event.faculty,
      className: event.className,
      course: event.course,
    );

    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (failure is AuthenticationFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Thông tin đăng nhập không chính xác.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NotFoundFailure) {
      return failure.message;
    } else if (failure is BadRequestFailure) {
      return failure.message;
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}
