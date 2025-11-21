import 'package:doan_hoi_app/src/domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    super.posterUrl,
    required super.startTime,
    required super.endTime,
    required super.registrationDeadline,
    required super.location,
    required super.organization,
    required super.eventType,
    required super.maxParticipants,
    required super.currentParticipants,
    required super.trainingPoints,
    required super.status,
    super.isRegistered,
    super.hasAttended,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final nowIso = DateTime.now().toIso8601String();
    final startIso = json['start_time'] ?? json['start_date'] ?? nowIso;
    final endIso = json['end_time'] ?? json['end_date'] ?? nowIso;
    final regDeadlineIso = json['registration_deadline'] ?? json['start_date'] ?? nowIso;
    final createdIso = json['created_at'] ?? json['start_date'] ?? nowIso;
    final updatedIso = json['updated_at'] ?? json['end_date'] ?? nowIso;

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is num) return v.toInt();
      final s = v.toString();
      final parsedD = double.tryParse(s);
      if (parsedD != null) return parsedD.round();
      final parsedI = int.tryParse(s);
      return parsedI ?? 0;
    }

    return EventModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      posterUrl: json['poster_url'] ?? json['image_url'],
      startTime: DateTime.tryParse(startIso) ?? DateTime.now(),
      endTime: DateTime.tryParse(endIso) ?? DateTime.now(),
      registrationDeadline: DateTime.tryParse(regDeadlineIso) ?? DateTime.now(),
      location: json['location'] ?? '',
      organization: json['organization'] ?? (json['union']?['name'] ?? ''),
      eventType: json['event_type'] ?? 'general',
      maxParticipants: _toInt(json['max_participants']),
      currentParticipants: _toInt(json['current_participants']),
      trainingPoints: _toInt(json['training_points'] ?? json['activity_points']),
      status: json['status'] ?? 'upcoming',
      isRegistered: json['is_registered'] ?? ((json['registration_status'] != null && json['registration_status'] != 'rejected') ? true : false),
      hasAttended: json['has_attended'] ?? false,
      createdAt: DateTime.tryParse(createdIso) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedIso) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'registration_deadline': registrationDeadline.toIso8601String(),
      'location': location,
      'organization': organization,
      'event_type': eventType,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'training_points': trainingPoints,
      'status': status,
      'is_registered': isRegistered,
      'has_attended': hasAttended,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
