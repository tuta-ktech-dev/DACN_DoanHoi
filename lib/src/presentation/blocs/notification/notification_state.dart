part of 'notification_cubit.dart';

final class NotificationState extends Equatable {
  const NotificationState({
    this.status = FetchingStatus.initial,
    this.notifications,
    this.pagination,
    this.unreadCount,
    this.errorMessage,
  });

  final FetchingStatus status;
  final List<Notification>? notifications;
  final PaginationInfo? pagination;
  final int? unreadCount;
  final String? errorMessage;

  bool get hasMore {
    if (pagination == null) return false;
    return pagination!.currentPage < pagination!.lastPage;
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        pagination,
        unreadCount,
        errorMessage,
      ];

  NotificationState copyWith({
    FetchingStatus? status,
    List<Notification>? notifications,
    PaginationInfo? pagination,
    int? unreadCount,
    String? errorMessage,
  }) =>
      NotificationState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        pagination: pagination ?? this.pagination,
        unreadCount: unreadCount ?? this.unreadCount,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

