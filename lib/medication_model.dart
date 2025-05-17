import 'package:flutter/material.dart';

class Medication {
  final String id;
  final String name;
  final int timesPerDay;
  final List<TimeOfDay> times;
  final DateTime startDate;
  final DateTime endDate;
  final String doctor;
  String symptoms;

  Medication({
    required this.id,
    required this.name,
    required this.timesPerDay,
    required this.times,
    required this.startDate,
    required this.endDate,
    required this.doctor,
    this.symptoms = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timesPerDay': timesPerDay,
      'times': times.map((t) => {'hour': t.hour, 'minute': t.minute}).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'doctor': doctor,
      'symptoms': symptoms,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      timesPerDay: json['timesPerDay'],
      times: (json['times'] as List).map((t) => TimeOfDay(hour: t['hour'], minute: t['minute'])).toList(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      doctor: json['doctor'],
      symptoms: json['symptoms'] ?? '',
    );
  }
} 