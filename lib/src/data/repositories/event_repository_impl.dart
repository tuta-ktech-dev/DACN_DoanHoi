import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/api_service.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/cms_api_service.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final ApiService _apiService;
  final CmsApiService _cmsApiService;

  EventRepositoryImpl(this._apiService, this._cmsApiService);

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    String? search,
    String? type,
    String? status,
    int? unionId,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) async {
    try {
      final events = await _cmsApiService.getEvents(
        status: status,
        unionId: unionId,
        page: page,
        perPage: limit,
      );

      return Right(events.data?.events?.map((e) => e.toEvent()).toList() ?? []);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể tải danh sách sự kiện'));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventDetail(String eventId) async {
    try {
      final event = await _apiService.getEventDetail(eventId);
      return Right(event.toEvent());
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể tải chi tiết sự kiện'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getMyEvents() async {
    try {
      final response = await _cmsApiService.getMyEvents();
      final events = response.data
              ?.map((item) => item.toEvent())
              .toList() ??
          [];
      return Right(events);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể tải sự kiện của bạn'));
    }
  }

  @override
  Future<Either<Failure, void>> registerEvent(String eventId) async {
    try {
      await _apiService.registerEvent(eventId);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể đăng ký sự kiện'));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterEvent(String eventId) async {
    try {
      await _apiService.unregisterEvent(eventId);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể hủy đăng ký sự kiện'));
    }
  }

  @override
  Future<Either<Failure, void>> attendEvent(
      String eventId, String qrToken) async {
    try {
      await _apiService.attendEvent(eventId, qrToken);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(ServerFailure('Không thể điểm danh sự kiện'));
    }
  }
}
