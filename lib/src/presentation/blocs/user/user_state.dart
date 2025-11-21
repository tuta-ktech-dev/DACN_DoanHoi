import 'package:equatable/equatable.dart';
import 'package:doan_hoi_app/src/domain/entities/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class ProfileLoaded extends UserState {
  final User user;

  const ProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class ActivityHistoryLoaded extends UserState {
  final List<Map<String, dynamic>> activities;

  const ActivityHistoryLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

class UserOperationSuccess extends UserState {
  final String message;

  const UserOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}