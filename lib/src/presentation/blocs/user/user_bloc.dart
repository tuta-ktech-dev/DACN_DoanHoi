import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(const UserInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
    on<LoadActivityHistoryEvent>(_onLoadActivityHistory);
  }

  Future<void> _onLoadProfile(LoadProfileEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    final result = await _userRepository.getProfile();

    result.fold(
      (failure) => emit(UserError(_mapFailureToMessage(failure))),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    final result = await _userRepository.updateProfile(event.data);

    result.fold(
      (failure) => emit(UserError(_mapFailureToMessage(failure))),
      (user) {
        emit(const UserOperationSuccess('Cập nhật thông tin thành công'));
        emit(ProfileLoaded(user));
      },
    );
  }

  Future<void> _onUploadAvatar(UploadAvatarEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    final result = await _userRepository.uploadAvatar(event.imagePath);

    result.fold(
      (failure) => emit(UserError(_mapFailureToMessage(failure))),
      (avatarUrl) {
        emit(const UserOperationSuccess('Tải lên ảnh đại diện thành công'));
        add(const LoadProfileEvent());
      },
    );
  }

  Future<void> _onLoadActivityHistory(LoadActivityHistoryEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());

    final result = await _userRepository.getActivityHistory();

    result.fold(
      (failure) => emit(UserError(_mapFailureToMessage(failure))),
      (activities) => emit(ActivityHistoryLoaded(activities)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NotFoundFailure) {
      return 'Không tìm thấy thông tin người dùng.';
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}
