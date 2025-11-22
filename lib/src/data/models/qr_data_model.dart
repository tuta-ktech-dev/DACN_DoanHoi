import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qr_data_model.g.dart';

@JsonSerializable(createToJson: false)
class QRDataModel extends Equatable {
  const QRDataModel({
    required this.token,
    required this.eventId,
    required this.expiresAt,
  });

  @JsonKey(name: 'token')
  final String token;

  @JsonKey(name: 'event_id')
  final int eventId;

  @JsonKey(name: 'expires_at')
  final String expiresAt;

  factory QRDataModel.fromJson(Map<String, dynamic> json) =>
      _$QRDataModelFromJson(json);

  @override
  List<Object?> get props => [token, eventId, expiresAt];
}
