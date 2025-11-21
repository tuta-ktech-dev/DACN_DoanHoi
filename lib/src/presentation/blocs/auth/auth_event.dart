import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String studentId;
  final String password;

  const LoginEvent({
    required this.studentId,
    required this.password,
  });

  @override
  List<Object> get props => [studentId, password];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

class RegisterEvent extends AuthEvent {
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String studentId;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String faculty;
  final String className;
  final String course;

  const RegisterEvent({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.studentId,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.faculty,
    required this.className,
    required this.course,
  });

  @override
  List<Object> get props => [
        fullName,
        username,
        email,
        password,
        studentId,
        phone,
        dateOfBirth,
        gender,
        faculty,
        className,
        course,
      ];
}