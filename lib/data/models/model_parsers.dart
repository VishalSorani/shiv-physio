/// Shared parsing helpers for data-layer models.
///
/// These helpers are intentionally simple (no codegen) and defensive against
/// Supabase / Dio decoding variations.
class ModelParsers {
  ModelParsers._();

  static DateTime? dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static DateTime dateTime(dynamic value, {required DateTime fallback}) {
    return dateTimeOrNull(value) ?? fallback;
  }

  static bool boolValue(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes') return true;
      if (v == 'false' || v == '0' || v == 'no') return false;
    }
    return fallback;
  }

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int intValue(dynamic value, {required int fallback}) {
    return intOrNull(value) ?? fallback;
  }

  static String? stringOrNull(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    return s.isEmpty ? null : s;
  }
}
