import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/presentation/blocs/fetch_event/fetch_event_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event_detail_state.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  EventDetailCubit(this._cmsApiService) : super(const EventDetailState());

  final CmsApiService _cmsApiService;

  Future<void> fetchEventDetail(int eventId) async {
    emit(const EventDetailState(status: FetchingStatus.loading));

    try {
      final eventResponse = await _cmsApiService.getEvent(eventId);
      if (eventResponse.success ?? false) {
        emit(state.copyWith(
            status: FetchingStatus.success,
            event: eventResponse.data?.toEvent()));
      } else {
        emit(state.copyWith(
            status: FetchingStatus.error,
            errorMessage: "Lỗi khi lấy chi tiết sự kiện"));
      }
    } catch (e) {
      emit(state.copyWith(
          status: FetchingStatus.error, errorMessage: e.toString()));
    }
  }
}
