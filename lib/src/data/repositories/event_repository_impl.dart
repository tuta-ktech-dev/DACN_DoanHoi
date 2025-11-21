import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/data/datasources/local/shared_preferences_manager.dart';
import 'package:doan_hoi_app/src/data/datasources/remote/api_service.dart';
import 'package:doan_hoi_app/src/data/models/event_model.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:doan_hoi_app/src/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final ApiService _apiService;
  final SharedPreferencesManager _sharedPreferences;

  EventRepositoryImpl(this._apiService, this._sharedPreferences);

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    String? search,
    String? type,
    String? status,
    String? organization,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) async {
    try {
      final events = await _apiService.getEvents(
        search: search,
        type: type,
        status: status,
        organization: organization,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      
      // Cache the events
      await _sharedPreferences.cacheEvents(events);
      
      return Right(events);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Không thể tải danh sách sự kiện'));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventDetail(String eventId) async {
    try {
      final event = await _apiService.getEventDetail(eventId);
      return Right(event);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Không thể tải chi tiết sự kiện'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getMyEvents() async {
    try {
      final events = await _apiService.getMyEvents();
      return Right(events);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Không thể tải sự kiện của bạn'));
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
      return Left(ServerFailure('Không thể đăng ký sự kiện'));
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
      return Left(ServerFailure('Không thể hủy đăng ký sự kiện'));
    }
  }

  @override
  Future<Either<Failure, void>> attendEvent(String eventId, String qrToken) async {
    try {
      await _apiService.attendEvent(eventId, qrToken);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Không thể điểm danh sự kiện'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getCachedEvents() async {
    try {
      final cachedEvents = await _sharedPreferences.getCachedEvents();
      if (cachedEvents != null) {
        return Right(cachedEvents);
      }
      return Left(CacheFailure('Không có dữ liệu cache'));
    } catch (e) {
      return Left(CacheFailure('Không thể đọc dữ liệu cache'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheEvents(List<Event> events) async {
    try {
      await _sharedPreferences.cacheEvents(events.cast<EventModel>());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Không thể lưu cache'));
    }
  }
}