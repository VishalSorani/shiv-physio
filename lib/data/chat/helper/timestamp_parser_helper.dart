import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for parsing Firestore Timestamps to DateTime
class TimestampParser {
  /// Parse a nullable timestamp to DateTime (returns null if input is null)
  static DateTime? parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return null;
    }
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    
    if (timestamp is DateTime) {
      return timestamp;
    }
    
    return null;
  }
  
  /// Parse a timestamp to DateTime with fallback to current time
  static DateTime parseTimestampWithDefault(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    
    if (timestamp is DateTime) {
      return timestamp;
    }
    
    return DateTime.now();
  }
}
