// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'union_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnionResponseModel _$UnionResponseModelFromJson(Map<String, dynamic> json) =>
    UnionResponseModel(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => UnionDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

UnionDataModel _$UnionDataModelFromJson(Map<String, dynamic> json) =>
    UnionDataModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      status: json['status'] as String?,
    );
