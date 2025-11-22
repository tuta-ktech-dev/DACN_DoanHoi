import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/models/attendance_history_response_model.dart';
import 'package:doan_hoi_app/src/domain/repositories/attendance_history_repository.dart';
import 'package:equatable/equatable.dart';

part 'attendance_history_state.dart';

class AttendanceHistoryCubit extends Cubit<AttendanceHistoryState> {
  final AttendanceHistoryRepository _attendanceHistoryRepository;

  AttendanceHistoryCubit(this._attendanceHistoryRepository)
      : super(AttendanceHistoryInitial());

  Future<void> fetchAttendanceHistory({String? status}) async {
    emit(AttendanceHistoryLoading());

    final result = await _attendanceHistoryRepository.getAttendanceHistory(
      status: status,
    );

    result.fold(
      (failure) => emit(AttendanceHistoryError(_mapFailureToMessage(failure))),
      (response) => emit(AttendanceHistoryLoaded(response.data ?? [])),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    }
    return 'Không thể tải lịch sử điểm danh';
  }
}
