import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/domain/repositories/event_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'fetch_event_state.dart';

class FetchEventCubit extends Cubit<FetchEventState> {
  final EventRepository _eventRepository;

  FetchEventCubit(this._eventRepository)
      : super(const FetchEventState(
          filter: FetchEventFilter(status: null, unionId: null),
        ));

  Future<void> fetchEvents() async {
    emit(state.copyWith(status: FetchingStatus.loading));
    final events = await _eventRepository.getEvents(
      status: state.filter?.status,
      unionId: state.filter?.unionId,
      page: state.page,
      limit: state.limit,
    );
    events.fold(
      (failure) => emit(state.copyWith(
          status: FetchingStatus.error, errorMessage: failure.message)),
      (events) => emit(state.copyWith(
        status: FetchingStatus.success,
        events: events,
        hasMore: events.length == state.limit,
      )),
    );
  }

  Future<void> fetchMoreEvents() async {
    if (!state.hasMore!) {
      return;
    }
    emit(state.copyWith(status: FetchingStatus.loadingMore));
    final events = await _eventRepository.getEvents(
      status: state.filter?.status,
      unionId: state.filter?.unionId,
      page: (state.page ?? 0) + 1,
      limit: state.limit,
    );
    events.fold(
      (failure) => emit(state.copyWith(
          status: FetchingStatus.error, errorMessage: failure.message)),
      (events) => emit(state.copyWith(
        events: [...state.events ?? [], ...events],
        hasMore: events.length == state.limit,
      )),
    );
  }

  void setFilter({String? status, int? unionId}) {
    emit(state.copyWith(
      filter: FetchEventFilter(
        status: status,
        unionId: unionId,
      ),
      page: 1, // Reset to page 1 when filter changes
      events: [], // Clear current events
    ));
    fetchEvents();
  }
}
