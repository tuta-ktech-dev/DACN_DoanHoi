import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/data/models/notification_response_model.dart';
import 'package:doan_hoi_app/src/domain/entities/notification.dart';
import 'package:doan_hoi_app/src/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final CmsApiService _cmsApiService;

  NotificationRepositoryImpl(this._cmsApiService);

  @override
  Future<Either<Failure, NotificationList>> getNotifications({
    String? type,
    bool? read,
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _cmsApiService.getNotifications(
        type: type,
        read: read,
        page: page,
        perPage: perPage,
      );

      if (response.success ?? false) {
        final data = response.data;
        if (data != null) {
          final notifications = data.notifications
                  ?.map((item) => _mapToNotification(item))
                  .whereType<Notification>()
                  .toList() ??
              [];

          final pagination = data.pagination;
          final paginationInfo = PaginationInfo(
            currentPage: pagination?.currentPage ?? 1,
            lastPage: pagination?.lastPage ?? 1,
            perPage: pagination?.perPage ?? 15,
            total: pagination?.total ?? 0,
          );

          return Right(NotificationList(
            notifications: notifications,
            pagination: paginationInfo,
            unreadCount: data.unreadCount ?? 0,
          ));
        }
      }

      return const Left(ServerFailure('Không thể tải thông báo'));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể tải thông báo'));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _cmsApiService.markNotificationAsRead(notificationId);
      if (response.success ?? false) {
        return const Right(null);
      }
      return const Left(ServerFailure('Không thể đánh dấu đã đọc'));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể đánh dấu đã đọc'));
    }
  }

  @override
  Future<Either<Failure, int>> markAllNotificationsAsRead() async {
    try {
      final response = await _cmsApiService.markAllNotificationsAsRead();
      if (response.success ?? false) {
        final markedCount = response.data?.markedCount ?? 0;
        return Right(markedCount);
      }
      return const Left(ServerFailure('Không thể đánh dấu tất cả đã đọc'));
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể đánh dấu tất cả đã đọc'));
    }
  }

  Notification? _mapToNotification(dynamic item) {
    if (item is! NotificationItemModel) return null;

    return Notification(
      id: item.id ?? 0,
      type: NotificationType.fromString(item.type) ?? NotificationType.registrationSuccess,
      title: item.title ?? '',
      message: item.message ?? '',
      data: item.data != null
          ? NotificationData(
              eventId: item.data!.eventId,
              eventTitle: item.data!.eventTitle,
              eventStartDate: item.data!.eventStartDate,
              eventLocation: item.data!.eventLocation,
              activityPoints: item.data!.activityPoints,
            )
          : null,
      isRead: item.isRead ?? false,
      readAt: item.readAt,
      createdAt: item.createdAt ?? DateTime.now(),
    );
  }
}

