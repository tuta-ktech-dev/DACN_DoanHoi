// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventResponseModel _$EventResponseModelFromJson(Map<String, dynamic> json) =>
    EventResponseModel(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : EventsDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

EventsDataModel _$EventsDataModelFromJson(Map<String, dynamic> json) =>
    EventsDataModel(
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => EventDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : PaginationDataModel.fromJson(
              json['pagination'] as Map<String, dynamic>),
    );

EventDataModel _$EventDataModelFromJson(Map<String, dynamic> json) =>
    EventDataModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      location: json['location'] as String?,
      maxParticipants: (json['max_participants'] as num?)?.toInt(),
      currentParticipants: (json['current_participants'] as num?)?.toInt(),
      activityPoints: json['activity_points'] as String?,
      imageUrl: json['image_url'] as String?,
      union: json['union'] == null
          ? null
          : UnionDataModel.fromJson(json['union'] as Map<String, dynamic>),
      registrationStatus: json['registration_status'] as String?,
      canRegister: json['can_register'] as bool?,
      status: json['status'] as String?,
    );

UnionDataModel _$UnionDataModelFromJson(Map<String, dynamic> json) =>
    UnionDataModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      logoUrl: json['logo_url'] as String?,
    );

PaginationDataModel _$PaginationDataModelFromJson(Map<String, dynamic> json) =>
    PaginationDataModel(
      currentPage: (json['current_page'] as num?)?.toInt(),
      lastPage: (json['last_page'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
    );
