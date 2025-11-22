import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/models/attendance_response_model.dart';
import 'package:doan_hoi_app/src/domain/repositories/attendance_repository.dart';
import 'package:equatable/equatable.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _attendanceRepository;

  AttendanceCubit(this._attendanceRepository) : super(AttendanceInitial());

  Future<void> scanQR(String qrData) async {
    emit(AttendanceProcessing());

    final result = await _attendanceRepository.scanQR(qrData);

    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        print('AttendanceCubit: Emitting AttendanceError: $message');
        emit(AttendanceError(message));
      },
      (response) {
        print('AttendanceCubit: Emitting AttendanceSuccess: ${response.success}, ${response.message}');
        emit(AttendanceSuccess(response));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is BadRequestFailure) {
      return failure.message;
    }
    return 'Đã xảy ra lỗi không xác định';
  }
}
