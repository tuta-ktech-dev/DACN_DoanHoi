// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceResponseModel _$AttendanceResponseModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : AttendanceDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

AttendanceDataModel _$AttendanceDataModelFromJson(Map<String, dynamic> json) =>
    AttendanceDataModel(
      attendance: json['attendance'] == null
          ? null
          : AttendanceModel.fromJson(
              json['attendance'] as Map<String, dynamic>),
      event: json['event'] == null
          ? null
          : EventDataModel.fromJson(json['event'] as Map<String, dynamic>),
      activityPointsEarned: json['activity_points_earned'] as String?,
    );

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: (json['id'] as num?)?.toInt(),
      status: json['status'] as String?,
      attendedAt: json['attended_at'] as String?,
    );
