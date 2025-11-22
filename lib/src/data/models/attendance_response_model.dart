import 'package:doan_hoi_app/src/data/models/event_response_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_response_model.g.dart';

@JsonSerializable(createToJson: false)
class AttendanceResponseModel extends Equatable {
  const AttendanceResponseModel({
    this.success,
    this.message,
    this.data,
  });

  final bool? success;
  final String? message;
  final AttendanceDataModel? data;

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable(createToJson: false)
class AttendanceDataModel extends Equatable {
  const AttendanceDataModel({
    this.attendance,
    this.event,
    this.activityPointsEarned,
  });

  final AttendanceModel? attendance;
  final EventDataModel? event;
  @JsonKey(name: 'activity_points_earned')
  final String? activityPointsEarned;

  factory AttendanceDataModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDataModelFromJson(json);

  @override
  List<Object?> get props => [attendance, event, activityPointsEarned];
}

@JsonSerializable(createToJson: false)
class AttendanceModel extends Equatable {
  const AttendanceModel({
    this.id,
    this.status,
    this.attendedAt,
  });

  final int? id;
  final String? status;
  @JsonKey(name: 'attended_at')
  final String? attendedAt;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  @override
  List<Object?> get props => [id, status, attendedAt];
}
