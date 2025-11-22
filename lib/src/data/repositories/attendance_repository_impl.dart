import 'dart:convert';
import 'package:dartz/dartz.dart';
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

      // Validate QR data
      final validationError = _validateQRData(qrModel);
      if (validationError != null) {
        return Left(ValidationFailure(validationError));
      }

      // Call API
      final attendanceResponse = await _cmsApiService.scanQR(qrModel.token);

      if (attendanceResponse.success) {
        return Right(attendanceResponse);
      } else {
        return Left(ServerFailure(attendanceResponse.message ?? ''));
      }
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Không thể xử lý mã QR'));
    }
  }

  String? _validateQRData(QRDataModel qrData) {
    // Validate token
    if (qrData.token.isEmpty || qrData.token.length != 32) {
      return 'Mã QR không hợp lệ';
    }

    // Validate event_id
    if (qrData.eventId <= 0) {
      return 'Mã QR không hợp lệ';
    }

    // Validate expiration
    try {
      final expiresAt = DateTime.parse(qrData.expiresAt);
      final now = DateTime.now();

      if (expiresAt.isBefore(now)) {
        return 'Mã QR đã hết hạn';
      }

      // Check if token expires in less than 5 seconds
      final fiveSecondsFromNow = now.add(const Duration(seconds: 5));
      if (expiresAt.isBefore(fiveSecondsFromNow)) {
        return 'Mã QR sắp hết hạn, vui lòng thử lại';
      }
    } catch (e) {
      return 'Mã QR không hợp lệ';
    }

    return null; // Valid
  }
}
