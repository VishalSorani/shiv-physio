// Subscription tiers
enum SubscriptionTier { free, premium, family }

// Subscription statuses
enum SubscriptionStatus { inactive, active, cancelled, expired }

// Circle types
enum CircleType { family, friends, work, other }

// Circle member roles
enum CircleMemberRole { admin, member, viewer }

// Location activity types
enum LocationActivityType { still, walking, running, cycling, driving, unknown }

// SOS alert status
enum SosStatus { active, resolved, false_alarm }

// SOS alert severity
enum SosSeverity { critical, high, medium, low }

// -----------------------------------------------------------------------------
// Supabase (Shiv Physio App) enums
// -----------------------------------------------------------------------------

/// Mirrors Postgres enum: `public.appointment_status`
enum AppointmentStatus { pending, confirmed, completed, cancelled, noShow }

/// Appointment request status for UI display
enum RequestStatus {
  newRequest,
  urgent,
}

extension AppointmentStatusMapper on AppointmentStatus {
  /// Converts enum to DB string (snake_case) used by Supabase/Postgres.
  String toDb() {
    return switch (this) {
      AppointmentStatus.pending => 'pending',
      AppointmentStatus.confirmed => 'confirmed',
      AppointmentStatus.completed => 'completed',
      AppointmentStatus.cancelled => 'cancelled',
      AppointmentStatus.noShow => 'no_show',
    };
  }

  /// Parses DB string (snake_case) into enum.
  static AppointmentStatus fromDb(String? value) {
    return switch (value) {
      'pending' => AppointmentStatus.pending,
      'confirmed' => AppointmentStatus.confirmed,
      'completed' => AppointmentStatus.completed,
      'cancelled' => AppointmentStatus.cancelled,
      'no_show' => AppointmentStatus.noShow,
      _ => AppointmentStatus.pending,
    };
  }
}
