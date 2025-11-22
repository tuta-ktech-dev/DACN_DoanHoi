part of 'attendance_cubit.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceProcessing extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final AttendanceResponseModel response;

  const AttendanceSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}
