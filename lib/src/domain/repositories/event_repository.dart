import 'package:dartz/dartz.dart';
import 'package:doan_hoi_app/src/core/error/failures.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';

abstract class EventRepository {
  Future<Either<Failure, List<Event>>> getEvents({
    String? search,
    String? type,
    String? status,
    int? unionId,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  });

  Future<Either<Failure, Event>> getEventDetail(String eventId);
  Future<Either<Failure, List<Event>>> getMyEvents();
  Future<Either<Failure, void>> registerEvent(String eventId);
  Future<Either<Failure, void>> unregisterEvent(String eventId);
  Future<Either<Failure, void>> attendEvent(String eventId, String qrToken);
}
