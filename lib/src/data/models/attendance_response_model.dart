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
  final EventModel? event;
  final int? activityPointsEarned;

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
  final String? attendedAt;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  @override
  List<Object?> get props => [id, status, attendedAt];
}

@JsonSerializable(createToJson: false)
class EventModel extends Equatable {
  const EventModel({
    this.id,
    this.title,
    this.activityPoints,
  });

  final int? id;
  final String? title;
  final int? activityPoints;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  @override
  List<Object?> get props => [id, title, activityPoints];
}
