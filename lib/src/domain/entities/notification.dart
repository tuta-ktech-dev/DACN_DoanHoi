import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? eventId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.eventId,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        eventId,
        isRead,
        createdAt,
        readAt,
      ];

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? eventId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      eventId: eventId ?? this.eventId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}