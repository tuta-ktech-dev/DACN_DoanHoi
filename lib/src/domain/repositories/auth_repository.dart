import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String studentId, String password);
  Future<Either<Failure, User>> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String studentId,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String faculty,
    required String className,
    required String course,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, String>> refreshToken();
  Future<Either<Failure, bool>> isAuthenticated();
}