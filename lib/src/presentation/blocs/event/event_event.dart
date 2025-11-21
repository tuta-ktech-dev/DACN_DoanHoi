import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

class LoadEventsEvent extends EventEvent {
  final String? search;
  final String? type;
  final String? status;
  final String? organization;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? page;
  final int? limit;

  const LoadEventsEvent({
    this.search,
    this.type,
    this.status,
    this.organization,
    this.startDate,
    this.endDate,
    this.page,
    this.limit,
  });

  @override
  List<Object> get props => [
        search ?? '',
        type ?? '',
        status ?? '',
        organization ?? '',
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now(),
        page ?? 1,
        limit ?? 20,
      ];
}

class LoadEventDetailEvent extends EventEvent {
  final String eventId;

  const LoadEventDetailEvent(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class LoadMyEventsEvent extends EventEvent {
  const LoadMyEventsEvent();
}

class RegisterEvent extends EventEvent {
  final String eventId;

  const RegisterEvent(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class UnregisterEvent extends EventEvent {
  final String eventId;

  const UnregisterEvent(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class AttendEvent extends EventEvent {
  final String eventId;
  final String qrToken;

  const AttendEvent(this.eventId, this.qrToken);

  @override
  List<Object> get props => [eventId, qrToken];
}

class RefreshEventsEvent extends EventEvent {
  const RefreshEventsEvent();
}