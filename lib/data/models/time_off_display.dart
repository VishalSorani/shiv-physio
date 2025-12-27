import 'package:flutter/material.dart';
import 'doctor_time_off.dart';

/// Model for displaying time off in the UI
class TimeOffDisplay {
  final String id;
  final String dateRange;
  final String reason;
  final IconData icon;
  final Color color;
  final DateTime startAt;
  final DateTime endAt;

  const TimeOffDisplay({
    required this.id,
    required this.dateRange,
    required this.reason,
    required this.icon,
    required this.color,
    required this.startAt,
    required this.endAt,
  });

  factory TimeOffDisplay.fromTimeOff(DoctorTimeOff timeOff) {
    final startDate = timeOff.startAt;
    final endDate = timeOff.endAt;
    final isSameDay =
        startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    String dateRange;
    if (isSameDay) {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      dateRange = '${months[startDate.month - 1]} ${startDate.day}';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      dateRange =
          '${months[startDate.month - 1]} ${startDate.day} - ${months[endDate.month - 1]} ${endDate.day}';
    }

    // Determine icon and color based on reason
    IconData icon = Icons.event_busy;
    Color color = Colors.purple;
    if (timeOff.reason?.toLowerCase().contains('vacation') == true ||
        timeOff.reason?.toLowerCase().contains('holiday') == true) {
      icon = Icons.beach_access;
      color = Colors.orange;
    }

    return TimeOffDisplay(
      id: timeOff.id,
      dateRange: dateRange,
      reason: timeOff.reason ?? 'Time Off',
      icon: icon,
      color: color,
      startAt: startDate,
      endAt: endDate,
    );
  }
}

