// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceHistoryResponseModel _$AttendanceHistoryResponseModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceHistoryResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) =>
              AttendanceHistoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

AttendanceHistoryItemModel _$AttendanceHistoryItemModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceHistoryItemModel(
      id: (json['id'] as num?)?.toInt(),
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      attendedAt: json['attended_at'] as String?,
      notes: json['notes'] as String?,
      activityPointsEarned: (json['activity_points_earned'] as num?)?.toInt(),
      event: json['event'] == null
          ? null
          : AttendanceHistoryEventModel.fromJson(
              json['event'] as Map<String, dynamic>),
    );

AttendanceHistoryEventModel _$AttendanceHistoryEventModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceHistoryEventModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      activityPoints: json['activity_points'] as String?,
      union: json['union'] == null
          ? null
          : AttendanceHistoryUnionModel.fromJson(
              json['union'] as Map<String, dynamic>),
    );

AttendanceHistoryUnionModel _$AttendanceHistoryUnionModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceHistoryUnionModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );
