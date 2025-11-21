import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/entities/notification.dart';
import 'package:doan_hoi_app/src/domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;

  NotificationBloc(this._notificationRepository)
      : super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllAsRead);
    on<ClearNotificationsEvent>(_onClearNotifications);
    on<ReceiveNotificationEvent>(_onReceiveNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // emit(const NotificationLoading());

    // final result = await _notificationRepository.getNotifications();
    // final unreadCountResult = await _notificationRepository.getUnreadCount();

    // result.fold(
    //   (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
    //   (notifications) {
    //     unreadCountResult.fold(
    //       (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
    //       (unreadCount) {
    //         emit(NotificationsLoaded(
    //           notifications: notifications,
    //           unreadCount: unreadCount,
    //         ));
    //       },
    //     );
    //   },
    // );
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result =
        await _notificationRepository.markAsRead(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
      (_) {
        // Reload notifications after marking as read
        add(const LoadNotificationsEvent());
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.markAllAsRead();

    result.fold(
      (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
      (_) {
        // Reload notifications after marking all as read
        add(const LoadNotificationsEvent());
      },
    );
  }

  Future<void> _onClearNotifications(
    ClearNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _notificationRepository.clearNotifications();

    result.fold(
      (failure) => emit(NotificationError(_mapFailureToMessage(failure))),
      (_) {
        // Reload notifications after clearing
        add(const LoadNotificationsEvent());
      },
    );
  }

  Future<void> _onReceiveNotification(
    ReceiveNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    // Create a new notification from the received data
    final newNotification = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      body: event.body,
      type: event.type,
      eventId: event.eventId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    // Save the notification
    await _notificationRepository.saveNotification(newNotification);

    // Reload notifications to include the new one
    add(const LoadNotificationsEvent());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (failure is CacheFailure) {
      return 'Không thể đọc dữ liệu cache.';
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}
