import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_register_response_model.g.dart';

@JsonSerializable(createToJson: false)
class EventRegisterResponseModel extends Equatable {
  const EventRegisterResponseModel({
    this.success,
    this.message,
  });

  final bool? success;
  final String? message;

  factory EventRegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EventRegisterResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, message];
}
