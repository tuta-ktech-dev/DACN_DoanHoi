import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile(Map<String, dynamic> data);
  Future<Either<Failure, String>> uploadAvatar(String imagePath);
  Future<Either<Failure, List<Map<String, dynamic>>>> getActivityHistory();
}