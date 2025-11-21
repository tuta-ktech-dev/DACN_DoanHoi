import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/local/shared_preferences_manager.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/api_service.dart';
import 'package:doan_hoi_app/src/data/models/notification_model.dart';
import 'package:doan_hoi_app/src/domain/entities/notification.dart';
import 'package:doan_hoi_app/src/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiService _apiService;
  final SharedPreferencesManager _sharedPreferences;

  NotificationRepositoryImpl(this._apiService, this._sharedPreferences);

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final notifications = await _apiService.getNotifications();

      // Cache the notifications
      await _sharedPreferences.cacheNotifications(notifications);

      return Right(notifications);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể tải thông báo'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể đánh dấu đã đọc'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      // Get all notifications and mark them as read locally
      final notifications = await getNotifications();
      return notifications.fold(
        (failure) => Left(failure),
        (notificationList) async {
          for (final notification in notificationList) {
            if (!notification.isRead) {
              await markAsRead(notification.id);
            }
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return const Left(ServerFailure('Không thể đánh dấu tất cả đã đọc'));
    }
  }

  @override
  Future<Either<Failure, void>> clearNotifications() async {
    try {
      await _apiService.clearNotifications();
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể xóa thông báo'));
    }
  }

  @override
  Future<Either<Failure, void>> saveNotification(
      NotificationEntity notification) async {
    try {
      // Save notification locally (for push notifications)
      final cachedNotifications =
          await _sharedPreferences.getCachedNotifications() ?? [];
      cachedNotifications.insert(0, notification as NotificationModel);
      await _sharedPreferences.cacheNotifications(cachedNotifications);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Không thể lưu thông báo'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>>
      getCachedNotifications() async {
    try {
      final cachedNotifications =
          await _sharedPreferences.getCachedNotifications();
      if (cachedNotifications != null) {
        return Right(cachedNotifications);
      }
      return const Left(CacheFailure('Không có dữ liệu cache'));
    } catch (e) {
      return const Left(CacheFailure('Không thể đọc dữ liệu cache'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final notifications = await getNotifications();
      return notifications.fold(
        (failure) => Left(failure),
        (notificationList) {
          final unreadCount = notificationList.where((n) => !n.isRead).length;
          return Right(unreadCount);
        },
      );
    } catch (e) {
      return const Left(ServerFailure('Không thể đếm thông báo chưa đọc'));
    }
  }
}
