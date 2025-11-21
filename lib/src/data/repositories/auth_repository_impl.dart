import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/local/shared_preferences_manager.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/api_service.dart';
import 'package:doan_hoi_app/src/domain/entities/user.dart';
import 'package:doan_hoi_app/src/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final SharedPreferencesManager _sharedPreferences;

  AuthRepositoryImpl(this._apiService, this._sharedPreferences);

  @override
  Future<Either<Failure, User>> login(String studentId, String password) async {
    try {
      final authResponse = await _apiService.login(studentId, password);

      // Save tokens
      await _sharedPreferences.saveAccessToken(authResponse.accessToken);
      await _sharedPreferences.saveRefreshToken(authResponse.refreshToken);

      // Set token in API service
      _apiService.setAccessToken(authResponse.accessToken);

      // Get user profile
      final userModel = await _apiService.getProfile();
      await _sharedPreferences.saveUserData(userModel);

      return Right(userModel);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Đăng nhập thất bại'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _apiService.logout();
      await _sharedPreferences.clearAuthData();
      _apiService.clearAccessToken();
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Đăng xuất thất bại'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String studentId,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String faculty,
    required String className,
    required String course,
  }) async {
    try {
      final authResponse = await _apiService.register(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
        studentId: studentId,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        faculty: faculty,
        className: className,
        course: course,
      );

      // Save tokens
      await _sharedPreferences.saveAccessToken(authResponse.accessToken);
      await _sharedPreferences.saveRefreshToken(authResponse.refreshToken);

      // Set token in API service
      _apiService.setAccessToken(authResponse.accessToken);

      // Get user profile
      final userModel = await _apiService.getProfile();
      await _sharedPreferences.saveUserData(userModel);

      return Right(userModel);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Đăng ký thất bại'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUser = await _sharedPreferences.getUserData();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // If not in cache, get from API
      final userModel = await _apiService.getProfile();
      await _sharedPreferences.saveUserData(userModel);
      return Right(userModel);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Không thể lấy thông tin người dùng'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = await _sharedPreferences.getRefreshToken();
      if (refreshToken == null) {
        return Left(AuthenticationFailure('Không tìm thấy refresh token'));
      }

      // Implement token refresh logic here
      // For now, return the existing token
      return Right(refreshToken);
    } catch (e) {
      return Left(ServerFailure('Không thể refresh token'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final accessToken = await _sharedPreferences.getAccessToken();
      if (accessToken == null) {
        return const Right(false);
      }

      // Set token in API service
      _apiService.setAccessToken(accessToken);

      // Try to get user profile to verify token is valid
      try {
        await _apiService.getProfile();
        return const Right(true);
      } catch (e) {
        // Token might be expired
        return const Right(false);
      }
    } catch (e) {
      return const Right(false);
    }
  }
}
