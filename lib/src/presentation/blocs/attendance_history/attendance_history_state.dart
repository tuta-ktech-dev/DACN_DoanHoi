part of 'attendance_history_cubit.dart';

abstract class AttendanceHistoryState extends Equatable {
  const AttendanceHistoryState();

  @override
  List<Object?> get props => [];
}

class AttendanceHistoryInitial extends AttendanceHistoryState {}

class AttendanceHistoryLoading extends AttendanceHistoryState {}

class AttendanceHistoryLoaded extends AttendanceHistoryState {
  final List<AttendanceHistoryItemModel> attendanceHistory;

  const AttendanceHistoryLoaded(this.attendanceHistory);

  @override
  List<Object?> get props => [attendanceHistory];
}

class AttendanceHistoryError extends AttendanceHistoryState {
  final String message;

  const AttendanceHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
