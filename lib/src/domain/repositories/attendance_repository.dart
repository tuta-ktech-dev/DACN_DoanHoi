import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/models/attendance_response_model.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceResponseModel>> scanQR(String qrData);
}
