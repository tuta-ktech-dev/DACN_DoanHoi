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
  final String? registrationStatus;
  final bool? canRegister;
  final String? status;

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
    String? registrationStatus,
    bool? canRegister,
    String? status,
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
