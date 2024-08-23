import 'package:flutter/material.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final int color;
  final DateTime endTime;
  final DateTime selectedDay;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.color,
    required this.endTime,
    required this.selectedDay,
  });

  Color get colorAsColor => Color(color);
}
