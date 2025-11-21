import 'package:dio/dio.dart';
import 'package:doan_hoi_app/src/data/models/event_response_model.dart';
import 'package:doan_hoi_app/src/data/models/event_register_response_model.dart';
import 'package:doan_hoi_app/src/data/models/union_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'cms_api_service.g.dart';

@RestApi(baseUrl: 'http://localhost:8000/api/')
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
}

// curl -X GET "http://localhost:8000/api/unions" \
