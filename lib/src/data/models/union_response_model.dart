import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'union_response_model.g.dart';

@JsonSerializable(createToJson: false)
class UnionResponseModel extends Equatable {
  const UnionResponseModel({
    required this.success,
    required this.data,
  });

  final bool? success;
  final List<UnionDataModel>? data;

  factory UnionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UnionResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class UnionDataModel extends Equatable {
  const UnionDataModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.status,
  });

  final int? id;
  final String? name;
  final String? description;
  final String? logoUrl;
  final String? status;

  factory UnionDataModel.fromJson(Map<String, dynamic> json) =>
      _$UnionDataModelFromJson(json);

  @override
  List<Object?> get props => [id, name, description, logoUrl, status];
}

// {
//   "success": true,
//   "data": [
//     {
//       "id": 1,
//       "name": "Đoàn Thanh niên",
//       "description": "Đoàn Thanh niên Cộng sản Hồ Chí Minh",
//       "logo_url": "https://example.com/storage/logos/doan.png",
//       "status": "active"
//     }
//   ]
// }
