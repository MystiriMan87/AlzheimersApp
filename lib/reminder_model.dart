import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

enum RepeatInterval {
  none,
  daily,
  weekly,
  monthly
}

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final TimeOfDay notificationTime;
  final String? imagePath;
  final RepeatInterval repeatInterval;
  bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.notificationTime,
    this.imagePath,
    this.repeatInterval = RepeatInterval.none,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledTime': scheduledTime.toIso8601String(),
      'notificationTime': {'hour': notificationTime.hour, 'minute': notificationTime.minute},
      'imagePath': imagePath,
      'repeatInterval': repeatInterval.index,
      'isCompleted': isCompleted,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final timeMap = json['notificationTime'] as Map<String, dynamic>;
    return Reminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      notificationTime: TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']),
      imagePath: json['imagePath'],
      repeatInterval: RepeatInterval.values[json['repeatInterval'] ?? 0],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
} 