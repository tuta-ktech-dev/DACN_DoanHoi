import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/domain/repositories/event_repository.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_events_state.dart';

class MyEventsCubit extends Cubit<MyEventsState> {
  final EventRepository _eventRepository;

  MyEventsCubit(this._eventRepository)
      : super(const MyEventsState(
          status: FetchingStatus.initial,
        ));

  Future<void> fetchMyEvents() async {
    emit(state.copyWith(status: FetchingStatus.loading));

    final result = await _eventRepository.getMyEvents();

    result.fold(
      (failure) => emit(state.copyWith(
        status: FetchingStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (events) {
        final now = DateTime.now();
        
        // Categorize events by time
        final upcomingEvents = events
            .where((e) => e.startDate != null && e.startDate!.isAfter(now))
            .toList();
        
        final ongoingEvents = events
            .where((e) =>
                e.startDate != null &&
                e.endDate != null &&
                e.startDate!.isBefore(now) &&
                e.endDate!.isAfter(now))
            .toList();
        
        final pastEvents = events
            .where((e) => e.endDate != null && e.endDate!.isBefore(now))
            .toList();

        emit(state.copyWith(
          status: FetchingStatus.success,
          upcomingEvents: upcomingEvents,
          ongoingEvents: ongoingEvents,
          pastEvents: pastEvents,
        ));
      },
    );
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

