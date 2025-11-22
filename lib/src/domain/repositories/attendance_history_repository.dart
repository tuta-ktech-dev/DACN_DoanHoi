import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/models/attendance_history_response_model.dart';

abstract class AttendanceHistoryRepository {
  Future<Either<Failure, AttendanceHistoryResponseModel>> getAttendanceHistory({
    String? status,
  });
}
