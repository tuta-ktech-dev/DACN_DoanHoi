import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/local/shared_preferences_manager.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/api_service.dart';
import 'package:doan_hoi_app/src/data/models/user_model.dart';
import 'package:doan_hoi_app/src/domain/entities/user.dart';
import 'package:doan_hoi_app/src/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;
  final SharedPreferencesManager _sharedPreferences;

  UserRepositoryImpl(this._apiService, this._sharedPreferences);

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final userModel = await _apiService.getProfile();
      await _sharedPreferences.saveUserData(userModel);
      return Right(userModel);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể tải thông tin cá nhân'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data) async {
    try {
      // This would typically be implemented in the API service
      // For now, we'll update the cached user data
      final currentUser = await _sharedPreferences.getUserData();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          studentId: data['studentId'] ?? currentUser.studentId,
          fullName: data['fullName'] ?? currentUser.fullName,
          email: data['email'] ?? currentUser.email,
          className: data['className'] ?? currentUser.className,
          faculty: data['faculty'] ?? currentUser.faculty,
          major: data['major'] ?? currentUser.major,
          updatedAt: DateTime.now(),
        );
        await _sharedPreferences
            .saveUserData(UserModel.fromEntity(updatedUser));
        return Right(updatedUser);
      }
      return const Left(NotFoundFailure('Không tìm thấy thông tin người dùng'));
    } catch (e) {
      return const Left(ServerFailure('Không thể cập nhật thông tin cá nhân'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String imagePath) async {
    try {
      // This would typically be implemented in the API service
      // For now, return a mock URL
      final mockAvatarUrl =
          'https://example.com/avatar/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Update cached user data
      final currentUser = await _sharedPreferences.getUserData();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          avatarUrl: mockAvatarUrl,
          updatedAt: DateTime.now(),
        );
        await _sharedPreferences
            .saveUserData(UserModel.fromEntity(updatedUser));
      }

      return Right(mockAvatarUrl);
    } catch (e) {
      return const Left(ServerFailure('Không thể tải lên ảnh đại diện'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getActivityHistory() async {
    try {
      // This would typically be implemented in the API service
      // For now, return mock data
      final mockActivities = [
        {
          'id': '1',
          'eventName': 'Hội thảo Khoa học 2024',
          'eventDate': '2024-11-15',
          'status': 'attended',
          'trainingPoints': 5,
        },
        {
          'id': '2',
          'eventName': 'Chương trình Tình nguyện Mùa hè',
          'eventDate': '2024-08-20',
          'status': 'attended',
          'trainingPoints': 10,
        },
        {
          'id': '3',
          'eventName': 'Giải bóng đá Khoa',
          'eventDate': '2024-07-10',
          'status': 'registered',
          'trainingPoints': 3,
        },
      ];

      return Right(mockActivities);
    } catch (e) {
      return const Left(ServerFailure('Không thể tải lịch sử hoạt động'));
    }
  }
}
