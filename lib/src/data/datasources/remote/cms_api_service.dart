import 'package:dio/dio.dart';
import 'package:doan_hoi_app/src/data/models/event_response_model.dart';
import 'package:doan_hoi_app/src/data/models/event_register_response_model.dart';
import 'package:doan_hoi_app/src/data/models/notification_response_model.dart';
import 'package:doan_hoi_app/src/data/models/union_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'cms_api_service.g.dart';

@RestApi(baseUrl: 'http://192.168.1.10:8000/api/')
abstract class CmsApiService {
  factory CmsApiService(Dio dio, {required String baseUrl}) = _CmsApiService;

  @GET('student/events')
  Future<EventResponseModel> getEvents({
    @Query('status') String? status, // upcoming, ongoing, completed
    @Query('union_id') int? unionId,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  @GET('student/events/{id}')
  Future<EventDetailResponseModel> getEvent(@Path('id') int eventId);

  @POST('student/events/{id}/register')
  Future<EventRegisterResponseModel> registerEvent(@Path('id') int eventId);

  @DELETE('student/events/{id}/unregister')
  Future<EventRegisterResponseModel> unregisterEvent(@Path('id') int eventId);

  @GET('unions')
  Future<UnionResponseModel> getUnions();

  @GET('student/registrations')
  Future<MyEventsResponseModel> getMyEvents();

  // Notification endpoints
  @GET('student/notifications')
  Future<NotificationResponseModel> getNotifications({
    @Query('type')
    String?
        type, // registration_success, unregistration_success, attendance_success
    @Query('read') bool? read, // true or false
    @Query('page') int? page,
    @Query('per_page') int? perPage,
  });

  @PUT('student/notifications/{id}/read')
  Future<MarkReadResponseModel> markNotificationAsRead(
      @Path('id') int notificationId);

  @PUT('student/notifications/read-all')
  Future<MarkReadResponseModel> markAllNotificationsAsRead();
}
