part of 'my_events_cubit.dart';

final class MyEventsState extends Equatable {
  const MyEventsState({
    this.status = FetchingStatus.initial,
    this.upcomingEvents = const [],
    this.ongoingEvents = const [],
    this.pastEvents = const [],
    this.errorMessage,
  });

  final FetchingStatus status;
  final List<Event> upcomingEvents;
  final List<Event> ongoingEvents;
  final List<Event> pastEvents;
  final String? errorMessage;

  @override
  List<Object?> get props => [
        status,
        upcomingEvents,
        ongoingEvents,
        pastEvents,
        errorMessage,
      ];

  MyEventsState copyWith({
    FetchingStatus? status,
    List<Event>? upcomingEvents,
    List<Event>? ongoingEvents,
    List<Event>? pastEvents,
    String? errorMessage,
  }) =>
      MyEventsState(
        status: status ?? this.status,
        upcomingEvents: upcomingEvents ?? this.upcomingEvents,
        ongoingEvents: ongoingEvents ?? this.ongoingEvents,
        pastEvents: pastEvents ?? this.pastEvents,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

