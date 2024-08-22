import 'package:flutter/material.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final int color;
  final DateTime endTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.color,
    required this.endTime,
  });

  Color get colorAsColor => Color(color);
}
