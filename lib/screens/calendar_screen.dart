import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../reminder_provider.dart';
import '../reminder_model.dart';
import '../widgets/background_container.dart';
import '../widgets/frosted_glass_box.dart';
import 'reminder_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final Color headerTextColor = Colors.white;
    final Color buttonColor = Colors.white.withOpacity(0.15);
    final Color buttonBorder = Colors.white.withOpacity(0.5);
    final Color chevronColor = Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FrostedGlassBox(
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Calendar'),
            elevation: 0,
          ),
        ),
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          return Column(
            children: [
              FrostedGlassBox(
                borderRadius: 12,
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  eventLoader: (day) {
                    return reminderProvider.reminders.where((reminder) {
                      return isSameDay(reminder.scheduledTime, day);
                    }).toList();
                  },
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                      color: headerTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: headerTextColor.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                    formatButtonDecoration: BoxDecoration(
                      color: buttonColor,
                      border: Border.all(color: buttonBorder),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: chevronColor, size: 28),
                    rightChevronIcon: Icon(Icons.chevron_right, color: chevronColor, size: 28),
                    formatButtonShowsNext: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedDay != null)
                Expanded(
                  child: _buildRemindersList(reminderProvider, _selectedDay!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRemindersList(ReminderProvider reminderProvider, DateTime day) {
    final reminders = reminderProvider.reminders.where((reminder) {
      return isSameDay(reminder.scheduledTime, day);
    }).toList();
    
    if (reminders.isEmpty) {
      return Center(
        child: Text(
          'No reminders for this day',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 18,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: reminders.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          color: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(
              reminder.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${reminder.notificationTime.format(context)} - ${reminder.description}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReminderDetailScreen(reminder: reminder),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 