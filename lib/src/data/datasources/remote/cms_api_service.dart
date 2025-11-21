import 'package:dio/dio.dart';
import 'package:doan_hoi_app/src/data/models/event_response_model.dart';
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
}
