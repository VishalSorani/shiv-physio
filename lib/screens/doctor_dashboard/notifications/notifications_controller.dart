import '../../../data/base_class/base_controller.dart';
import '../../../data/models/notification.dart' as notification_model;
import '../../../data/modules/notification_repository.dart';

class DoctorNotificationsController extends BaseController {
  static const String contentId = 'doctor_notifications_content';
  static const String listId = 'doctor_notifications_list';
  static const String emptyStateId = 'doctor_notifications_empty_state';

  final NotificationRepository _notificationRepository;

  DoctorNotificationsController(this._notificationRepository);

  // Notification data
  List<notification_model.Notification> _notifications = [];
  List<notification_model.Notification> get notifications => _notifications;

  bool get isEmpty => _notifications.isEmpty && !isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    await handleAsyncOperation(() async {
      _notifications = await _notificationRepository.getUserNotifications();
      update([listId, emptyStateId]);
    }, showLoadingIndicator: false);
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  Future<void> markAsRead(notification_model.Notification notification) async {
    if (notification.isRead) return;

    await handleAsyncOperation(() async {
      await _notificationRepository.markNotificationAsRead(notification.id);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(readAt: DateTime.now());
        update([listId]);
      }
    });
  }

  Future<void> markAllAsRead() async {
    await handleAsyncOperation(() async {
      await _notificationRepository.markAllNotificationsAsRead();

      // Update local state
      _notifications = _notifications.map((n) {
        if (!n.isRead) {
          return n.copyWith(readAt: DateTime.now());
        }
        return n;
      }).toList();

      update([listId]);
    });
  }

  void onNotificationTap(notification_model.Notification notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      markAsRead(notification);
    }

    // Handle navigation based on notification type
    switch (notification.notificationType) {
      case 'appointment_booked':
      case 'appointment_approved':
      case 'appointment_cancelled':
      case 'appointment_rejected':
        if (notification.relatedId != null) {
          // Navigate to appointment details or appointments screen
          // TODO: Implement navigation
        }
        break;
      default:
        // No specific action
        break;
    }
  }

  @override
  void handleNetworkChange(bool isConnected) {
    handleNetworkChangeDefault(isConnected);
    if (isConnected) {
      loadNotifications();
    }
  }
}
