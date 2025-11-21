import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? posterUrl;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime registrationDeadline;
  final String location;
  final String organization;
  final String eventType;
  final int maxParticipants;
  final int currentParticipants;
  final int trainingPoints;
  final String status; // upcoming, ongoing, completed
  final bool isRegistered;
  final bool hasAttended;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.posterUrl,
    required this.startTime,
    required this.endTime,
    required this.registrationDeadline,
    required this.location,
    required this.organization,
    required this.eventType,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.trainingPoints,
    required this.status,
    this.isRegistered = false,
    this.hasAttended = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRegistrationOpen {
    return DateTime.now().isBefore(registrationDeadline) && 
           currentParticipants < maxParticipants &&
           status == 'upcoming';
  }

  bool get canCancelRegistration {
    return isRegistered && DateTime.now().isBefore(startTime);
  }

  bool get canAttend {
    return isRegistered && 
           DateTime.now().isAfter(startTime) && 
           DateTime.now().isBefore(endTime) &&
           !hasAttended;
  }

  // Cached formatted strings for performance
  String get formattedStartTime {
    return '${startTime.day}/${startTime.month}/${startTime.year} ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get participantsText {
    return '$currentParticipants/$maxParticipants người';
  }

  String get trainingPointsText {
    return '$trainingPoints điểm rèn luyện';
  }

  String get statusText {
    switch (status) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return 'Không xác định';
    }
  }

  String get buttonStatusText {
    if (hasAttended) {
      return 'Đã điểm danh';
    } else if (isRegistered && !isRegistrationOpen) {
      return 'Đã đăng ký';
    } else if (status == 'completed') {
      return 'Đã kết thúc';
    } else if (currentParticipants >= maxParticipants) {
      return 'Đã đủ người';
    } else {
      return 'Không thể đăng ký';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        posterUrl,
        startTime,
        endTime,
        registrationDeadline,
        location,
        organization,
        eventType,
        maxParticipants,
        currentParticipants,
        trainingPoints,
        status,
        isRegistered,
        hasAttended,
        createdAt,
        updatedAt,
      ];

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? registrationDeadline,
    String? location,
    String? organization,
    String? eventType,
    int? maxParticipants,
    int? currentParticipants,
    int? trainingPoints,
    String? status,
    bool? isRegistered,
    bool? hasAttended,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      location: location ?? this.location,
      organization: organization ?? this.organization,
      eventType: eventType ?? this.eventType,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      trainingPoints: trainingPoints ?? this.trainingPoints,
      status: status ?? this.status,
      isRegistered: isRegistered ?? this.isRegistered,
      hasAttended: hasAttended ?? this.hasAttended,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}