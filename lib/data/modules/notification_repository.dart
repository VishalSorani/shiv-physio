import 'package:dio/dio.dart';
import '../base_class/base_repository.dart';
import '../models/appointment.dart';
import '../models/notification.dart' as notification_model;
import '../models/user.dart' as model;
import '../service/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for sending push notifications via OneSignal
///
/// NOTE: This implementation uses OneSignal REST API directly.
/// For production, consider using a backend service or Supabase Edge Functions
/// to keep the OneSignal REST API key secure.
class NotificationRepository extends BaseRepository {
  final SupabaseClient _supabase;
  final Dio _dio;

  // OneSignal REST API endpoint
  static const String _onesignalApiUrl =
      'https://onesignal.com/api/v1/notifications';

  // OneSignal App ID
  static const String _onesignalAppId = '534bfa2f-3aad-4158-8c0f-2fdec84feae3';

  // TODO: IMPORTANT - Configure OneSignal REST API Key
  //
  // To send notifications, you need to:
  // 1. Get your REST API Key from OneSignal Dashboard:
  //    Settings > Keys & IDs > REST API Key
  // 2. Store it securely (environment variables, backend service, or secure storage)
  // 3. Replace 'YOUR_REST_API_KEY_HERE' with your actual REST API Key
  //
  // For production, consider:
  // - Using Supabase Edge Functions to send notifications (keeps API key secure)
  // - Storing the key in environment variables
  // - Using a backend service to handle notifications
  //
  // Current implementation uses OneSignal REST API directly from the app.
  // This is functional but less secure than using a backend service.
  static const String _onesignalRestApiKey =
      'os_v2_app_knf7ulz2vvavrdapf7pmqt7k4m6qxduhtekeldfczi4zhtm4tqi3rdrsuj5xpo7brndszrkq4tu4mh5nihf3dcao2cpx3zia3sfzsxq';

  final StorageService _storageService;

  NotificationRepository({
    required SupabaseClient supabase,
    required StorageService storageService,
    Dio? dio,
  }) : _supabase = supabase,
       _storageService = storageService,
       _dio = dio ?? Dio();

  /// Get user's OneSignal ID from database
  Future<String?> getUserOneSignalId(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('onesignal_id')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return response['onesignal_id'] as String?;
    } catch (e) {
      logE('Error fetching user OneSignal ID', error: e);
      return null;
    }
  }

  /// Get doctor's OneSignal ID
  Future<String?> getDoctorOneSignalId() async {
    try {
      final doctorIdResponse = await _supabase.rpc('get_doctor_id');
      final doctorId = doctorIdResponse?.toString();

      if (doctorId == null || doctorId.isEmpty) {
        return null;
      }

      return await getUserOneSignalId(doctorId);
    } catch (e) {
      logE('Error fetching doctor OneSignal ID', error: e);
      return null;
    }
  }

  /// Send notification to a specific user by OneSignal ID
  Future<bool> sendNotificationToUser({
    required String onesignalId,
    required String userId,
    required String title,
    required String message,
    required String notificationType,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (_onesignalRestApiKey == 'YOUR_REST_API_KEY_HERE') {
        logW('OneSignal REST API key not configured. Notification not sent.');
        return false;
      }

      final payload = {
        'app_id': _onesignalAppId,
        'include_player_ids': [onesignalId],
        'headings': {'en': title},
        'contents': {'en': message},
        if (data != null) 'data': data,
      };

      final response = await _dio.post(
        _onesignalApiUrl,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Basic $_onesignalRestApiKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        logI('Notification sent successfully to user: $onesignalId');
        
        // Save notification to database
        await saveNotificationToDatabase(
          userId: userId,
          title: title,
          message: message,
          notificationType: notificationType,
          relatedId: relatedId,
          data: data,
          onesignalId: onesignalId,
        );
        
        return true;
      } else {
        logW('Failed to send notification. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      logE('Error sending notification', error: e);
      return false;
    }
  }

  /// Save notification to database
  Future<void> saveNotificationToDatabase({
    required String userId,
    required String title,
    required String message,
    required String notificationType,
    String? relatedId,
    Map<String, dynamic>? data,
    String? onesignalId,
  }) async {
    try {
      final notificationData = {
        'user_id': userId,
        'title': title,
        'message': message,
        'notification_type': notificationType,
        'related_id': relatedId,
        'data': data,
        'onesignal_id': onesignalId,
        'sent_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _supabase.from('notifications').insert(notificationData);
      logI('Notification saved to database for user: $userId');
    } catch (e) {
      logE('Error saving notification to database', error: e);
      // Don't throw - notification save failure shouldn't break the flow
    }
  }

  /// Get notifications for current user
  Future<List<notification_model.Notification>> getUserNotifications({
    int? limit,
    bool unreadOnly = false,
  }) async {
    try {
      final user = _storageService.getUser();
      if (user == null) {
        logW('No user found in storage');
        return [];
      }

      dynamic query = _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('sent_at', ascending: false);

      if (unreadOnly) {
        query = query.isFilter('read_at', null);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      if (response.isEmpty) {
        return [];
      }

      final notifications = (response as List)
          .map((json) => notification_model.Notification.fromJson(json))
          .toList();

      logI('Fetched ${notifications.length} notifications');
      return notifications;
    } catch (e) {
      logE('Error fetching notifications', error: e);
      handleRepositoryError(e);
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', notificationId);

      logI('Notification marked as read: $notificationId');
    } catch (e) {
      logE('Error marking notification as read', error: e);
      handleRepositoryError(e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final user = _storageService.getUser();
      if (user == null) {
        logW('No user found in storage');
        return;
      }

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('user_id', user.id)
          .isFilter('read_at', null);

      logI('All notifications marked as read');
    } catch (e) {
      logE('Error marking all notifications as read', error: e);
      handleRepositoryError(e);
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final user = _storageService.getUser();
      if (user == null) {
        return 0;
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .isFilter('read_at', null);

      return (response as List).length;
    } catch (e) {
      logE('Error getting unread notification count', error: e);
      return 0;
    }
  }

  /// Send notification on appointment booking
  Future<void> sendAppointmentBookedNotification({
    required Appointment appointment,
    required model.User patient,
  }) async {
    try {
      // Send to doctor
      final doctorOneSignalId = await getDoctorOneSignalId();
      if (doctorOneSignalId != null) {
        final patientName = patient.fullName ?? 'A patient';
        final formattedDate = _formatDateTime(appointment.startAt);

        await sendNotificationToUser(
          onesignalId: doctorOneSignalId,
          userId: appointment.doctorId,
          title: 'New Appointment Request',
          message:
              '$patientName has requested an appointment on $formattedDate',
          notificationType: 'appointment_booked',
          relatedId: appointment.id,
          data: {
            'type': 'appointment_booked',
            'appointment_id': appointment.id,
            'patient_id': appointment.patientId,
          },
        );
      }

      // Send to patient
      final patientOneSignalId = await getUserOneSignalId(
        appointment.patientId,
      );
      if (patientOneSignalId != null) {
        final formattedDate = _formatDateTime(appointment.startAt);

        await sendNotificationToUser(
          onesignalId: patientOneSignalId,
          userId: appointment.patientId,
          title: 'Appointment Requested',
          message:
              'Your appointment request for $formattedDate has been submitted',
          notificationType: 'appointment_booked',
          relatedId: appointment.id,
          data: {
            'type': 'appointment_booked',
            'appointment_id': appointment.id,
          },
        );
      }
    } catch (e) {
      logE('Error sending appointment booked notification', error: e);
      // Don't throw - notification failure shouldn't break the flow
    }
  }

  /// Send notification on appointment cancellation
  Future<void> sendAppointmentCancelledNotification({
    required Appointment appointment,
    required model.User cancelledBy,
    String? reason,
  }) async {
    try {
      final isDoctor = cancelledBy.isDoctor;
      final cancelledByName =
          cancelledBy.fullName ?? (isDoctor ? 'Doctor' : 'Patient');

      // Determine who to notify
      String? targetOneSignalId;
      String title;
      String message;

      if (isDoctor) {
        // Doctor cancelled - notify patient
        targetOneSignalId = await getUserOneSignalId(appointment.patientId);
        title = 'Appointment Cancelled';
        message =
            'Your appointment on ${_formatDateTime(appointment.startAt)} has been cancelled by $cancelledByName';
        if (reason != null && reason.isNotEmpty) {
          message += '. Reason: $reason';
        }
      } else {
        // Patient cancelled - notify doctor
        targetOneSignalId = await getDoctorOneSignalId();
        title = 'Appointment Cancelled';
        message =
            '$cancelledByName has cancelled the appointment on ${_formatDateTime(appointment.startAt)}';
        if (reason != null && reason.isNotEmpty) {
          message += '. Reason: $reason';
        }
      }

      if (targetOneSignalId != null) {
        final targetUserId = isDoctor ? appointment.patientId : appointment.doctorId;
        await sendNotificationToUser(
          onesignalId: targetOneSignalId,
          userId: targetUserId,
          title: title,
          message: message,
          notificationType: 'appointment_cancelled',
          relatedId: appointment.id,
          data: {
            'type': 'appointment_cancelled',
            'appointment_id': appointment.id,
            'cancelled_by': cancelledBy.id,
          },
        );
      }
    } catch (e) {
      logE('Error sending appointment cancelled notification', error: e);
      // Don't throw - notification failure shouldn't break the flow
    }
  }

  /// Send notification on appointment approval
  Future<void> sendAppointmentApprovedNotification({
    required Appointment appointment,
    required model.User patient,
  }) async {
    try {
      final patientOneSignalId = await getUserOneSignalId(
        appointment.patientId,
      );
      if (patientOneSignalId != null) {
        final formattedDate = _formatDateTime(appointment.startAt);

        await sendNotificationToUser(
          onesignalId: patientOneSignalId,
          userId: appointment.patientId,
          title: 'Appointment Confirmed',
          message: 'Your appointment on $formattedDate has been confirmed',
          notificationType: 'appointment_approved',
          relatedId: appointment.id,
          data: {
            'type': 'appointment_approved',
            'appointment_id': appointment.id,
          },
        );
      }
    } catch (e) {
      logE('Error sending appointment approved notification', error: e);
      // Don't throw - notification failure shouldn't break the flow
    }
  }

  /// Send notification on appointment rejection
  Future<void> sendAppointmentRejectedNotification({
    required Appointment appointment,
    required model.User patient,
    String? reason,
  }) async {
    try {
      final patientOneSignalId = await getUserOneSignalId(
        appointment.patientId,
      );
      if (patientOneSignalId != null) {
        final formattedDate = _formatDateTime(appointment.startAt);
        var message =
            'Your appointment request for $formattedDate has been declined';
        if (reason != null && reason.isNotEmpty) {
          message += '. Reason: $reason';
        }

        await sendNotificationToUser(
          onesignalId: patientOneSignalId,
          userId: appointment.patientId,
          title: 'Appointment Declined',
          message: message,
          notificationType: 'appointment_rejected',
          relatedId: appointment.id,
          data: {
            'type': 'appointment_rejected',
            'appointment_id': appointment.id,
          },
        );
      }
    } catch (e) {
      logE('Error sending appointment rejected notification', error: e);
      // Don't throw - notification failure shouldn't break the flow
    }
  }

  /// Format DateTime for notification messages
  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final dateStr = '${localTime.day}/${localTime.month}/${localTime.year}';
    final timeStr =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }
}
