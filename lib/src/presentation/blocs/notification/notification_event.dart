import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();
}

class ClearNotificationsEvent extends NotificationEvent {
  const ClearNotificationsEvent();
}

class ReceiveNotificationEvent extends NotificationEvent {
  final String title;
  final String body;
  final String type;
  final String? eventId;

  const ReceiveNotificationEvent({
    required this.title,
    required this.body,
    required this.type,
    this.eventId,
  });

  @override
  List<Object> get props => [title, body, type, eventId ?? ''];
}