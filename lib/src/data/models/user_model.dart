import 'package:doan_hoi_app/src/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.studentId,
    required super.fullName,
    required super.email,
    super.avatarUrl,
    required super.className,
    required super.faculty,
    required super.major,
    required super.trainingPoints,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String _asString(dynamic v) => v == null ? '' : v.toString();
    int _asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }
    DateTime _asDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return UserModel(
      id: _asString(json['id']),
      studentId: _asString(json['student_id']),
      fullName: _asString(json['full_name']),
      email: _asString(json['email']),
      avatarUrl: json['avatar_url'],
      className: _asString(json['class_name']),
      faculty: _asString(json['faculty']),
      major: _asString(json['major']),
      trainingPoints: _asInt(json['training_points']),
      createdAt: _asDate(json['created_at']),
      updatedAt: _asDate(json['updated_at']),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      studentId: user.studentId,
      fullName: user.fullName,
      email: user.email,
      avatarUrl: user.avatarUrl,
      className: user.className,
      faculty: user.faculty,
      major: user.major,
      trainingPoints: user.trainingPoints,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'class_name': className,
      'faculty': faculty,
      'major': major,
      'training_points': trainingPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
