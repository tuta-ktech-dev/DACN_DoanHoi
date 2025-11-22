import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_history_response_model.g.dart';

@JsonSerializable(createToJson: false)
class AttendanceHistoryResponseModel extends Equatable {
  const AttendanceHistoryResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final List<AttendanceHistoryItemModel>? data;

  factory AttendanceHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceHistoryResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable(createToJson: false)
class AttendanceHistoryItemModel extends Equatable {
  const AttendanceHistoryItemModel({
    this.id,
    this.status,
    this.statusLabel,
    this.attendedAt,
    this.notes,
    this.activityPointsEarned,
    this.event,
  });

  final int? id;
  final String? status;
  @JsonKey(name: 'status_label')
  final String? statusLabel;
  @JsonKey(name: 'attended_at')
  final String? attendedAt;
  final String? notes;
  @JsonKey(name: 'activity_points_earned')
  final String? activityPointsEarned;
  final AttendanceHistoryEventModel? event;

  factory AttendanceHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceHistoryItemModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        status,
        statusLabel,
        attendedAt,
        notes,
        activityPointsEarned,
        event,
      ];
}

@JsonSerializable(createToJson: false)
class AttendanceHistoryEventModel extends Equatable {
  const AttendanceHistoryEventModel({
    this.id,
    this.title,
    this.startDate,
    this.endDate,
    this.activityPoints,
    this.union,
  });

  final int? id;
  final String? title;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'activity_points')
  final String? activityPoints;
  final AttendanceHistoryUnionModel? union;

  factory AttendanceHistoryEventModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceHistoryEventModelFromJson(json);

  @override
  List<Object?> get props => [
        id,
        title,
        startDate,
        endDate,
        activityPoints,
        union,
      ];
}

@JsonSerializable(createToJson: false)
class AttendanceHistoryUnionModel extends Equatable {
  const AttendanceHistoryUnionModel({
    this.id,
    this.name,
  });

  final int? id;
  final String? name;

  factory AttendanceHistoryUnionModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceHistoryUnionModelFromJson(json);

  @override
  List<Object?> get props => [id, name];
}
