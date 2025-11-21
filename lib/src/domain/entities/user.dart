import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String studentId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String className;
  final String faculty;
  final String major;
  final int trainingPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.className,
    required this.faculty,
    required this.major,
    required this.trainingPoints,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        fullName,
        email,
        avatarUrl,
        className,
        faculty,
        major,
        trainingPoints,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    String? id,
    String? studentId,
    String? fullName,
    String? email,
    String? avatarUrl,
    String? className,
    String? faculty,
    String? major,
    int? trainingPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      className: className ?? this.className,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      trainingPoints: trainingPoints ?? this.trainingPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}