import 'package:doan_hoi_app/src/domain/entities/notification.dart';
import 'package:doan_hoi_app/src/domain/repositories/notification_repository.dart'
    show NotificationRepository, PaginationInfo;
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationCubit(this._notificationRepository)
      : super(const NotificationState(
          status: FetchingStatus.initial,
        ));

  Future<void> fetchNotifications({
    String? type,
    bool? read,
    int page = 1,
    int perPage = 15,
  }) async {
    // Reset to page 1 when refreshing
    emit(state.copyWith(
      status: FetchingStatus.loading,
      notifications: page == 1 ? [] : state.notifications, // Clear on first page
    ));

    final result = await _notificationRepository.getNotifications(
      type: type,
      read: read,
      page: page,
      perPage: perPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FetchingStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (notificationList) => emit(state.copyWith(
        status: FetchingStatus.success,
        notifications: notificationList.notifications,
        pagination: notificationList.pagination,
        unreadCount: notificationList.unreadCount,
      )),
    );
  }

  Future<void> fetchMoreNotifications() async {
    if (!state.hasMore || state.status == FetchingStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: FetchingStatus.loadingMore));

    final nextPage = (state.pagination?.currentPage ?? 1) + 1;
    final result = await _notificationRepository.getNotifications(
      page: nextPage,
      perPage: state.pagination?.perPage ?? 15,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FetchingStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (notificationList) => emit(state.copyWith(
        status: FetchingStatus.success,
        notifications: [
          ...state.notifications ?? [],
          ...notificationList.notifications,
        ],
        pagination: notificationList.pagination,
        unreadCount: notificationList.unreadCount,
      )),
    );
  }

  Future<void> markAsRead(int notificationId) async {
    final result = await _notificationRepository.markNotificationAsRead(notificationId);

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) {
        // Update notification in list
        final updatedNotifications = state.notifications?.map((notification) {
          if (notification.id == notificationId) {
            return Notification(
              id: notification.id,
              type: notification.type,
              title: notification.title,
              message: notification.message,
              data: notification.data,
              isRead: true,
              readAt: DateTime.now(),
              createdAt: notification.createdAt,
            );
          }
          return notification;
        }).toList();

        emit(state.copyWith(
          notifications: updatedNotifications,
          unreadCount: (state.unreadCount ?? 0) - 1,
        ));
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await _notificationRepository.markAllNotificationsAsRead();

    result.fold(
      (failure) => emit(state.copyWith(
        errorMessage: _mapFailureToMessage(failure),
      )),
      (markedCount) {
        // Update all notifications to read
        final updatedNotifications = state.notifications?.map((notification) {
          return Notification(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            data: notification.data,
            isRead: true,
            readAt: DateTime.now(),
            createdAt: notification.createdAt,
          );
        }).toList();

        emit(state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      },
    );
  }

  String _mapFailureToMessage(dynamic failure) {
    if (failure.toString().contains('Network')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (failure.toString().contains('Authentication')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else {
      return failure.toString().isNotEmpty
          ? failure.toString()
          : 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}

