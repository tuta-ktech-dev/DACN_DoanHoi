import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/data/models/attendance_history_response_model.dart';
import 'package:doan_hoi_app/src/domain/repositories/attendance_history_repository.dart';

class AttendanceHistoryRepositoryImpl implements AttendanceHistoryRepository {
  final CmsApiService _cmsApiService;

  AttendanceHistoryRepositoryImpl(this._cmsApiService);

  @override
  Future<Either<Failure, AttendanceHistoryResponseModel>> getAttendanceHistory({
    String? status,
  }) async {
    try {
      final response = await _cmsApiService.getAttendanceHistory(status: status);

      if (response.success) {
        return Right(response);
      } else {
        return Left(ServerFailure(response.message ?? ''));
      }
    } catch (e) {
      return Left(ServerFailure('Không thể tải lịch sử điểm danh'));
    }
  }
}
