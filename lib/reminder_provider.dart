import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reminder_model.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];
  final SharedPreferences _prefs;

  ReminderProvider(this._prefs) {
    _loadReminders();
  }

  List<Reminder> get reminders => _reminders;

  Future<void> _loadReminders() async {
    final String? remindersJson = _prefs.getString('reminders');
    if (remindersJson != null) {
      final List<dynamic> decoded = json.decode(remindersJson);
      _reminders = decoded.map((item) => Reminder.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveReminders() async {
    final String encoded = json.encode(_reminders.map((r) => r.toJson()).toList());
    await _prefs.setString('reminders', encoded);
  }

  Future<void> addReminder(Reminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _saveReminders();
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> toggleReminderCompletion(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      _reminders[index] = Reminder(
        id: reminder.id,
        title: reminder.title,
        description: reminder.description,
        scheduledTime: reminder.scheduledTime,
        notificationTime: reminder.notificationTime,
        imagePath: reminder.imagePath,
        repeatInterval: reminder.repeatInterval,
        isCompleted: !reminder.isCompleted,
      );
      await _saveReminders();
      notifyListeners();
    }
  }
} 