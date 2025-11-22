// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QRDataModel _$QRDataModelFromJson(Map<String, dynamic> json) => QRDataModel(
      token: json['token'] as String,
      eventId: (json['event_id'] as num).toInt(),
      expiresAt: json['expires_at'] as String,
    );
