import 'package:equatable/equatable.dart';

class Event extends Equatable {
  const Event({
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
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final int? maxParticipants;
  final int? currentParticipants;
  final String? activityPoints;
  final String? imageUrl;
  final Union? union;
  final RegistrationStatus? registrationStatus;
  final Registration? registration;
  final bool? canRegister;
  final EventStatus? status;

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    int? maxParticipants,
    int? currentParticipants,
    String? activityPoints,
    String? imageUrl,
    Union? union,
    RegistrationStatus? registrationStatus,
    Registration? registration,
    bool? canRegister,
    EventStatus? status,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      activityPoints: activityPoints ?? this.activityPoints,
      imageUrl: imageUrl ?? this.imageUrl,
      union: union ?? this.union,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      registration: registration ?? this.registration,
      canRegister: canRegister ?? this.canRegister,
      status: status ?? this.status,
    );
  }

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

class Union extends Equatable {
  const Union({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  final int? id;
  final String? name;
  final String? logoUrl;

  Union copyWith({
    int? id,
    String? name,
    String? logoUrl,
  }) {
    return Union(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
      ];
}

enum EventStatus {
  upcoming('upcoming'),
  ongoing('ongoing'),
  completed('completed');

  final String value;

  const EventStatus(this.value);
}

enum RegistrationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  cancelled('cancelled');

  final String value;

  const RegistrationStatus(this.value);
}

extension RegistrationStatusExtension on RegistrationStatus? {
  String get text {
    switch (this) {
      case null:
        return 'Chưa đăng ký';
      case RegistrationStatus.pending:
        return 'Đang chờ xét duyệt';
      case RegistrationStatus.approved:
        return 'Đã đăng ký thành công';
      case RegistrationStatus.rejected:
        return 'Đã bị từ chối';
      case RegistrationStatus.cancelled:
        return 'Đã bị hủy';
    }
  }

  String get buttonText {
    switch (this) {
      case null:
        return 'Đăng ký';
      case RegistrationStatus.pending:
        return 'Hủy đăng ký';
      case RegistrationStatus.approved:
        return 'Hủy đăng ký';
      case RegistrationStatus.rejected:
        return 'Hủy đăng ký';
      case RegistrationStatus.cancelled:
        return 'Hủy đăng ký';
    }
  }
}

// flutter: ║             "registration": {id: 447, status: pending, registered_at: 2025-11-21T20:19:08.000000Z, notes: null},

class Registration extends Equatable {
  const Registration({
    required this.id,
    required this.status,
    required this.registeredAt,
    required this.notes,
  });

  final int? id;
  final RegistrationStatus? status;
  final DateTime? registeredAt;
  final String? notes;

  Registration copyWith({
    int? id,
    RegistrationStatus? status,
    DateTime? registeredAt,
    String? notes,
  }) {
    return Registration(
      id: id ?? this.id,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, status, registeredAt, notes];
}
