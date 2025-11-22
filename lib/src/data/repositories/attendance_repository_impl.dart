import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/data/models/attendance_response_model.dart';
import 'package:doan_hoi_app/src/data/models/qr_data_model.dart';
import 'package:doan_hoi_app/src/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final CmsApiService _cmsApiService;

  AttendanceRepositoryImpl(this._cmsApiService);

  @override
  Future<Either<Failure, AttendanceResponseModel>> scanQR(String qrData) async {
    try {
      // Parse QR data JSON
      final qrMap = json.decode(qrData) as Map<String, dynamic>;

      final qrModel = QRDataModel.fromJson(qrMap);

      // Call API
      final attendanceResponse =
          await _cmsApiService.scanQR({'token': qrModel.token});

      if (attendanceResponse.success != null && attendanceResponse.success!) {
        return Right(attendanceResponse);
      } else {
        return Left(ServerFailure(attendanceResponse.message ?? ''));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? ''));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
