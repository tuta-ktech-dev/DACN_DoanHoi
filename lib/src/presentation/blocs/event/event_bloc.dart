import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository _eventRepository;

  EventBloc(this._eventRepository) : super(const EventInitial()) {
    on<LoadEventsEvent>(_onLoadEvents);
    on<LoadEventDetailEvent>(_onLoadEventDetail);
    on<LoadMyEventsEvent>(_onLoadMyEvents);
    on<RegisterEvent>(_onRegisterEvent);
    on<UnregisterEvent>(_onUnregisterEvent);
    on<AttendEvent>(_onAttendEvent);
    on<RefreshEventsEvent>(_onRefreshEvents);
  }

  Future<void> _onLoadEvents(
      LoadEventsEvent event, Emitter<EventState> emit) async {
    if (state is! EventsLoaded) {
      emit(const EventLoading());
    }

    final result = await _eventRepository.getEvents(
      search: event.search,
      type: event.type,
      status: event.status,
      unionId: event.unionId ?? 1,
      startDate: event.startDate,
      endDate: event.endDate,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(EventError(_mapFailureToMessage(failure))),
      (events) {
        final currentState = state;
        if (currentState is EventsLoaded &&
            event.page != null &&
            event.page! > 1) {
          // Pagination: append new events to existing list
          emit(EventsLoaded(
            events: currentState.events + events,
            hasReachedMax: events.length < (event.limit ?? 20),
            currentPage: event.page ?? 1,
          ));
        } else {
          emit(EventsLoaded(
            events: events,
            hasReachedMax: events.length < (event.limit ?? 20),
            currentPage: event.page ?? 1,
          ));
        }
      },
    );
  }

  Future<void> _onLoadEventDetail(
      LoadEventDetailEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());

    final result = await _eventRepository.getEventDetail(event.eventId);

    result.fold(
      (failure) => emit(EventError(_mapFailureToMessage(failure))),
      (eventDetail) => emit(EventDetailLoaded(eventDetail)),
    );
  }

  Future<void> _onLoadMyEvents(
      LoadMyEventsEvent event, Emitter<EventState> emit) async {
    emit(const EventLoading());

    // final result = await _eventRepository.getMyEvents();

    // result.fold(
    //   (failure) => emit(EventError(_mapFailureToMessage(failure))),
    //   (events) {
    //     final now = DateTime.now();
    //     final upcomingEvents =
    //         events.where((e) => e.startDate!.isAfter(now)).toList();
    //     final ongoingEvents = events
    //         .where((e) => e.startDate!.isBefore(now) && e.endDate!.isAfter(now))
    //         .toList();
    //     final pastEvents =
    //         events.where((e) => e.endDate!.isBefore(now)).toList();

    //     emit(MyEventsLoaded(
    //       upcomingEvents: upcomingEvents,
    //       ongoingEvents: ongoingEvents,
    //       pastEvents: pastEvents,
    //     ));
    //   },
    // );
  }

  Future<void> _onRegisterEvent(
      RegisterEvent event, Emitter<EventState> emit) async {
    final result = await _eventRepository.registerEvent(event.eventId);

    result.fold(
      (failure) => emit(EventError(_mapFailureToMessage(failure))),
      (_) {
        emit(const EventOperationSuccess('Đăng ký sự kiện thành công'));
        // Refresh events to update registration status
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onUnregisterEvent(
      UnregisterEvent event, Emitter<EventState> emit) async {
    final result = await _eventRepository.unregisterEvent(event.eventId);

    result.fold(
      (failure) => emit(EventError(_mapFailureToMessage(failure))),
      (_) {
        emit(const EventOperationSuccess('Hủy đăng ký sự kiện thành công'));
        // Refresh events to update registration status
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onAttendEvent(
      AttendEvent event, Emitter<EventState> emit) async {
    final result =
        await _eventRepository.attendEvent(event.eventId, event.qrToken);

    result.fold(
      (failure) => emit(EventError(_mapFailureToMessage(failure))),
      (_) {
        emit(const EventOperationSuccess('Điểm danh thành công'));
        // Refresh events to update attendance status
        add(const RefreshEventsEvent());
      },
    );
  }

  Future<void> _onRefreshEvents(
      RefreshEventsEvent event, Emitter<EventState> emit) async {
    // Reload current events
    if (state is EventsLoaded) {
      final currentState = state as EventsLoaded;
      add(LoadEventsEvent(
        page: 1,
        limit: currentState.events.length,
      ));
    } else if (state is MyEventsLoaded) {
      add(const LoadMyEventsEvent());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
    } else if (failure is AuthenticationFailure) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NotFoundFailure) {
      return 'Không tìm thấy sự kiện.';
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}
