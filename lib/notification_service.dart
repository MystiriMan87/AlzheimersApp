import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';
import 'reminder_model.dart' as models;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Callback for handling notification taps
  Function(String)? onNotificationTapped;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    final DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings = InitializationSettings(
      iOS: iOSSettings,
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // Request permissions for iOS
    await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // Handle iOS notification when app is in foreground
    if (payload != null) {
      onNotificationTapped?.call(payload);
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      onNotificationTapped?.call(response.payload!);
    }
  }

  Future<void> scheduleNotification(models.Reminder reminder) async {
    // Cancel any existing notification for this reminder
    await cancelNotification(reminder.id);
    
    DateTime scheduledDate = DateTime(
      reminder.scheduledTime.year,
      reminder.scheduledTime.month,
      reminder.scheduledTime.day,
      reminder.notificationTime.hour,
      reminder.notificationTime.minute,
    );
    
    if (scheduledDate.isBefore(DateTime.now())) {
      switch (reminder.repeatInterval) {
        case models.RepeatInterval.daily:
          scheduledDate = scheduledDate.add(const Duration(days: 1));
          break;
        case models.RepeatInterval.weekly:
          scheduledDate = scheduledDate.add(const Duration(days: 7));
          break;
        case models.RepeatInterval.monthly:
          scheduledDate = DateTime(
            scheduledDate.year,
            scheduledDate.month + 1,
            scheduledDate.day,
            scheduledDate.hour,
            scheduledDate.minute,
          );
          break;
        case models.RepeatInterval.none:
          return; // Don't schedule if it's a one-time reminder in the past
      }
    }
    
    final DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
      attachments: reminder.imagePath != null
          ? [DarwinNotificationAttachment(reminder.imagePath!)]
          : null,
      categoryIdentifier: 'reminder_category',
    );
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
      styleInformation: reminder.imagePath != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(reminder.imagePath!),
              hideExpandedLargeIcon: false,
              contentTitle: reminder.title,
              summaryText: 'Reminder',
            )
          : BigTextStyleInformation(
              reminder.description,
              contentTitle: reminder.title,
              summaryText: 'Reminder',
            ),
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      iOS: iOSDetails,
      android: androidDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.id,
    );
  }

  Future<void> cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
} 