import 'package:equatable/equatable.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {
  const EventInitial();
}

class EventLoading extends EventState {
  const EventLoading();
}

class EventsLoaded extends EventState {
  final List<Event> events;
  final bool hasReachedMax;
  final int currentPage;

  const EventsLoaded({
    required this.events,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [events, hasReachedMax, currentPage];
}

class EventDetailLoaded extends EventState {
  final Event event;

  const EventDetailLoaded(this.event);

  @override
  List<Object> get props => [event];
}

class MyEventsLoaded extends EventState {
  final List<Event> upcomingEvents;
  final List<Event> ongoingEvents;
  final List<Event> pastEvents;

  const MyEventsLoaded({
    required this.upcomingEvents,
    required this.ongoingEvents,
    required this.pastEvents,
  });

  @override
  List<Object> get props => [upcomingEvents, ongoingEvents, pastEvents];
}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object> get props => [message];
}

class EventOperationSuccess extends EventState {
  final String message;

  const EventOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}