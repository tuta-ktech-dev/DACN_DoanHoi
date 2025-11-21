part of 'event_detail_cubit.dart';

final class EventDetailState extends Equatable {
  const EventDetailState({
    this.status = FetchingStatus.initial,
    this.event,
    this.errorMessage,
  });

  final FetchingStatus status;
  final Event? event;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, event, errorMessage ?? ''];

  EventDetailState copyWith({
    FetchingStatus? status,
    Event? event,
    String? errorMessage,
  }) =>
      EventDetailState(
        status: status ?? this.status,
        event: event ?? this.event,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
