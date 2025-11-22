import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  const Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationData? data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, type, title, message, data, isRead, readAt, createdAt];
}

class NotificationData extends Equatable {
  const NotificationData({
    this.eventId,
    this.eventTitle,
    this.eventStartDate,
    this.eventLocation,
    this.activityPoints,
  });

  final int? eventId;
  final String? eventTitle;
  final String? eventStartDate;
  final String? eventLocation;
  final String? activityPoints;

  @override
  List<Object?> get props =>
      [eventId, eventTitle, eventStartDate, eventLocation, activityPoints];
}

enum NotificationType {
  registrationSuccess('registration_success'),
  unregistrationSuccess('unregistration_success'),
  attendanceSuccess('attendance_success');

  final String value;
  const NotificationType(this.value);

  static NotificationType? fromString(String? value) {
    if (value == null) return null;
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.registrationSuccess,
    );
  }

  String get label {
    switch (this) {
      case NotificationType.registrationSuccess:
        return 'Đăng ký thành công';
      case NotificationType.unregistrationSuccess:
        return 'Hủy đăng ký thành công';
      case NotificationType.attendanceSuccess:
        return 'Điểm danh thành công';
    }
  }
}
