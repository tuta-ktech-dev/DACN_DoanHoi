import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends UserEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends UserEvent {
  final Map<String, dynamic> data;

  const UpdateProfileEvent(this.data);

  @override
  List<Object> get props => [data];
}

class UploadAvatarEvent extends UserEvent {
  final String imagePath;

  const UploadAvatarEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class LoadActivityHistoryEvent extends UserEvent {
  const LoadActivityHistoryEvent();
}