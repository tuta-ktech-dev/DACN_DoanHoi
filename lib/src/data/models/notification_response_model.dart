import 'package:doan_hoi_app/src/data/models/event_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_response_model.g.dart';

@JsonSerializable(createToJson: false)
class NotificationResponseModel extends Equatable {
  const NotificationResponseModel({
    required this.success,
    required this.data,
  });

  final bool? success;
  final NotificationDataModel? data;

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class NotificationDataModel extends Equatable {
  const NotificationDataModel({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  final List<NotificationItemModel>? notifications;
  final PaginationDataModel? pagination;

  @JsonKey(name: 'unread_count')
  final int? unreadCount;

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataModelFromJson(json);

  @override
  List<Object?> get props => [notifications, pagination, unreadCount];
}

@JsonSerializable(createToJson: false)
class NotificationItemModel extends Equatable {
  const NotificationItemModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  final int? id;
  final String? type;
  final String? title;
  final String? message;
  final NotificationDataItemModel? data;

  @JsonKey(name: 'is_read')
  final bool? isRead;

  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemModelFromJson(json);

  @override
  List<Object?> get props =>
      [id, type, title, message, data, isRead, readAt, createdAt];
}

@JsonSerializable(createToJson: false)
class NotificationDataItemModel extends Equatable {
  const NotificationDataItemModel({
    this.eventId,
    this.eventTitle,
    this.eventStartDate,
    this.eventLocation,
    this.activityPoints,
  });

  @JsonKey(name: 'event_id')
  final int? eventId;

  @JsonKey(name: 'event_title')
  final String? eventTitle;

  @JsonKey(name: 'event_start_date')
  final String? eventStartDate;

  @JsonKey(name: 'event_location')
  final String? eventLocation;

  @JsonKey(name: 'activity_points')
  final String? activityPoints;

  factory NotificationDataItemModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataItemModelFromJson(json);

  @override
  List<Object?> get props =>
      [eventId, eventTitle, eventStartDate, eventLocation, activityPoints];
}

@JsonSerializable(createToJson: false)
class MarkReadResponseModel extends Equatable {
  const MarkReadResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool? success;
  final String? message;
  final MarkReadDataModel? data;

  factory MarkReadResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MarkReadResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable(createToJson: false)
class MarkReadDataModel extends Equatable {
  const MarkReadDataModel({
    this.markedCount,
  });

  @JsonKey(name: 'marked_count')
  final int? markedCount;

  factory MarkReadDataModel.fromJson(Map<String, dynamic> json) =>
      _$MarkReadDataModelFromJson(json);

  @override
  List<Object?> get props => [markedCount];
}
