import 'user.dart';
import 'appointment.dart';

/// Model for displaying patient information in the patient management screen
class PatientDisplay {
  final User patient;
  final Appointment? nextAppointment;
  final Appointment? lastAppointment;
  final String? condition; // Primary condition/treatment type
  final int? progressPercentage; // Treatment progress (0-100)
  final String? status; // active, pending_review, etc.

  const PatientDisplay({
    required this.patient,
    this.nextAppointment,
    this.lastAppointment,
    this.condition,
    this.progressPercentage,
    this.status,
  });

  /// Get patient initials for avatar
  String get initials {
    final name = patient.fullName ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get formatted patient ID
  String get formattedId {
    // Extract numeric part from patient ID or use last 4 digits
    final id = patient.id;
    if (id.length >= 4) {
      return '#${id.substring(id.length - 4)}';
    }
    return '#${id.substring(0, id.length)}';
  }

  /// Get patient age string
  String? get ageString {
    if (patient.age != null) {
      return '${patient.age} yrs';
    }
    return null;
  }

  /// Get formatted next appointment date/time
  String? get nextAppointmentString {
    if (nextAppointment == null) return null;
    final date = nextAppointment!.startAt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(date.year, date.month, date.day);

    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    final timeString = '$displayHour:$displayMinute $period';

    if (appointmentDate == today) {
      return 'Today, $timeString';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, $timeString';
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
      return '${months[date.month - 1]} ${date.day}, $timeString';
    }
  }

  /// Get formatted last visit date
  String? get lastVisitString {
    if (lastAppointment == null) return null;
    final date = lastAppointment!.startAt;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }

  /// Get status badge color
  String? get statusBadgeColor {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'green';
      case 'pending_review':
        return 'yellow';
      case 'completed':
        return 'blue';
      default:
        return null;
    }
  }
}
