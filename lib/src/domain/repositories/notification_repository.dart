import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<Notification>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> clearNotifications();
  Future<Either<Failure, void>> saveNotification(Notification notification);
  Future<Either<Failure, List<Notification>>> getCachedNotifications();
  Future<Either<Failure, int>> getUnreadCount();
}