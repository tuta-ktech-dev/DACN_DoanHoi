// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponseModel _$NotificationResponseModelFromJson(
        Map<String, dynamic> json) =>
    NotificationResponseModel(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : NotificationDataModel.fromJson(
              json['data'] as Map<String, dynamic>),
    );

NotificationDataModel _$NotificationDataModelFromJson(
        Map<String, dynamic> json) =>
    NotificationDataModel(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map(
              (e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : PaginationDataModel.fromJson(
              json['pagination'] as Map<String, dynamic>),
      unreadCount: (json['unread_count'] as num?)?.toInt(),
    );

NotificationItemModel _$NotificationItemModelFromJson(
        Map<String, dynamic> json) =>
    NotificationItemModel(
      id: (json['id'] as num?)?.toInt(),
      type: json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : NotificationDataItemModel.fromJson(
              json['data'] as Map<String, dynamic>),
      isRead: json['is_read'] as bool?,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

NotificationDataItemModel _$NotificationDataItemModelFromJson(
        Map<String, dynamic> json) =>
    NotificationDataItemModel(
      eventId: (json['event_id'] as num?)?.toInt(),
      eventTitle: json['event_title'] as String?,
      eventStartDate: json['event_start_date'] as String?,
      eventLocation: json['event_location'] as String?,
      activityPoints: json['activity_points'] as String?,
    );

MarkReadResponseModel _$MarkReadResponseModelFromJson(
        Map<String, dynamic> json) =>
    MarkReadResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : MarkReadDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

MarkReadDataModel _$MarkReadDataModelFromJson(Map<String, dynamic> json) =>
    MarkReadDataModel(
      markedCount: (json['marked_count'] as num?)?.toInt(),
    );