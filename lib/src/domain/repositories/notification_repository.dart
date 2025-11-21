import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationList>> getNotifications({
    String? type,
    bool? read,
    int? page,
    int? perPage,
  });

  Future<Either<Failure, void>> markNotificationAsRead(int notificationId);
  Future<Either<Failure, int>> markAllNotificationsAsRead();
}

class NotificationList {
  const NotificationList({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  final List<Notification> notifications;
  final PaginationInfo pagination;
  final int unreadCount;
}

class PaginationInfo {
  const PaginationInfo({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
}
