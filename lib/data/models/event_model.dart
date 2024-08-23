import 'package:calendar_app/domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    super.id,
    required super.title,
    required super.description,
    required super.location,
    required super.startTime,
    required super.color,
    required super.endTime,
    required super.selectedDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'color': color,
      'selectedDay': selectedDay.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      color: int.parse(map['color']),
      selectedDay: DateTime.parse(map['selectedDay']),
    );
  }
}
