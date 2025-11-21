import 'package:collection/collection.dart';
import 'package:doan_hoi_app/src/domain/entities/event.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_response_model.g.dart';

@JsonSerializable(createToJson: false)
class EventDetailResponseModel extends Equatable {
  const EventDetailResponseModel({
    required this.success,
    required this.data,
  });

  final bool? success;
  final EventDataModel? data;

  factory EventDetailResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EventDetailResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class EventResponseModel extends Equatable {
  const EventResponseModel({
    required this.success,
    required this.data,
  });

  final bool? success;
  final EventsDataModel? data;

  factory EventResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EventResponseModelFromJson(json);

  @override
  List<Object?> get props => [
        success,
        data,
      ];
}

@JsonSerializable(createToJson: false)
class EventsDataModel extends Equatable {
  const EventsDataModel({
    required this.events,
    required this.pagination,
  });

  final List<EventDataModel>? events;
  final PaginationDataModel? pagination;

  factory EventsDataModel.fromJson(Map<String, dynamic> json) =>
      _$EventsDataModelFromJson(json);

  @override
  List<Object?> get props => [
        events,
        pagination,
      ];
}

@JsonSerializable(createToJson: false)
class EventDataModel extends Equatable {
  const EventDataModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.activityPoints,
    required this.imageUrl,
    required this.union,
    required this.registrationStatus,
    required this.registration,
    required this.canRegister,
    required this.status,
  });

  final int? id;
  final String? title;
  final String? description;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  final String? location;

  @JsonKey(name: 'max_participants')
  final int? maxParticipants;

  @JsonKey(name: 'current_participants')
  final int? currentParticipants;

  @JsonKey(name: 'activity_points')
  final String? activityPoints;

  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final UnionDataModel? union;

  @JsonKey(name: 'registration_status')
  final String? registrationStatus;

  @JsonKey(name: 'registration')
  final RegistrationDataModel? registration;

  @JsonKey(name: 'can_register')
  final bool? canRegister;
  final String? status;

  factory EventDataModel.fromJson(Map<String, dynamic> json) =>
      _$EventDataModelFromJson(json);

  Event toEvent() => Event(
        id: id,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        location: location,
        maxParticipants: maxParticipants,
        currentParticipants: currentParticipants,
        activityPoints: activityPoints,
        imageUrl: imageUrl,
        union: union?.toUnion(),
        registrationStatus: RegistrationStatus.values.firstWhereOrNull(
          (e) => e.value == registrationStatus,
        ),
        registration: registration?.toRegistration(),
        canRegister: canRegister,
        status: EventStatus.values.firstWhere(
          (e) => e.value == status,
          orElse: () => EventStatus.upcoming,
        ),
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startDate,
        endDate,
        location,
        maxParticipants,
        currentParticipants,
        activityPoints,
        imageUrl,
        union,
        registrationStatus,
        registration,
        canRegister,
        status,
      ];
}

@JsonSerializable(createToJson: false)
class UnionDataModel extends Equatable {
  const UnionDataModel({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  final int? id;
  final String? name;

  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  factory UnionDataModel.fromJson(Map<String, dynamic> json) =>
      _$UnionDataModelFromJson(json);

  Union toUnion() => Union(
        id: id,
        name: name,
        logoUrl: logoUrl,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
      ];
}

@JsonSerializable(createToJson: false)
class PaginationDataModel extends Equatable {
  const PaginationDataModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'last_page')
  final int? lastPage;

  @JsonKey(name: 'per_page')
  final int? perPage;
  final int? total;

  factory PaginationDataModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationDataModelFromJson(json);

  @override
  List<Object?> get props => [
        currentPage,
        lastPage,
        perPage,
        total,
      ];
}

@JsonSerializable(createToJson: false)
class RegistrationDataModel extends Equatable {
  const RegistrationDataModel({
    required this.id,
    required this.status,
    required this.registeredAt,
    required this.notes,
  });

  final int? id;
  final String? status;
  final DateTime? registeredAt;
  final String? notes;

  factory RegistrationDataModel.fromJson(Map<String, dynamic> json) =>
      _$RegistrationDataModelFromJson(json);

  Registration toRegistration() => Registration(
        id: id,
        status: RegistrationStatus.values.firstWhereOrNull(
          (e) => e.value == status,
        ),
        registeredAt: registeredAt,
        notes: notes,
      );

  @override
  List<Object?> get props => [id, status, registeredAt, notes];
}

@JsonSerializable(createToJson: false)
class MyEventsResponseModel extends Equatable {
  const MyEventsResponseModel({
    required this.success,
    required this.data,
  });

  final bool? success;
  final List<MyEventRegistrationModel>? data;

  factory MyEventsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MyEventsResponseModelFromJson(json);

  @override
  List<Object?> get props => [success, data];
}

@JsonSerializable(createToJson: false)
class MyEventRegistrationModel extends Equatable {
  const MyEventRegistrationModel({
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.registeredAt,
    required this.notes,
    required this.event,
  });

  final int? id;
  final String? status;

  @JsonKey(name: 'status_label')
  final String? statusLabel;

  @JsonKey(name: 'registered_at')
  final DateTime? registeredAt;
  final String? notes;
  final EventDataModel? event;

  factory MyEventRegistrationModel.fromJson(Map<String, dynamic> json) =>
      _$MyEventRegistrationModelFromJson(json);

  Event toEvent() {
    final eventModel = event;
    if (eventModel == null) {
      throw Exception('Event data is null');
    }

    // Create registration from registration fields
    final registration = RegistrationDataModel(
      id: id,
      status: status,
      registeredAt: registeredAt,
      notes: notes,
    );

    // Merge registration info into event
    return eventModel.toEvent().copyWith(
          registration: registration.toRegistration(),
        );
  }

  @override
  List<Object?> get props =>
      [id, status, statusLabel, registeredAt, notes, event];
}
