// lib/services/notification_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();
  late StreamController<int> _unreadCountController;
  Timer? _pollingTimer;
  bool _isDisposed = false;

  NotificationService() {
    _unreadCountController = StreamController<int>.broadcast();
  }

  // Stream to listen to unread notification count changes
  Stream<int> get unreadCount => _unreadCountController.stream;

  // Start polling for unread notifications
  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    if (_pollingTimer?.isActive ?? false) {
      return; // Already polling
    }

    print('🔔 Starting notification count polling every ${interval.inSeconds}s');

    // Poll immediately
    _fetchUnreadCount();

    // Then poll at regular intervals
    _pollingTimer = Timer.periodic(interval, (_) {
      if (!_isDisposed) {
        _fetchUnreadCount();
      }
    });
  }

  // Stop polling
  void stopPolling() {
    print('🔔 Stopping notification polling');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      final response = await _apiService.get('orders/notifications/');
      return response['notifications'] ?? [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get('orders/notifications/unread/count/');
      return response['count'] ?? 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  // Fetch unread notification count and update stream
  Future<int> _fetchUnreadCount() async {
    try {
      final response = await _apiService.get('orders/notifications/unread/count/');

      if (response != null && response['count'] != null) {
        final count = response['count'] as int;
        print('🔔 Unread notifications: $count');

        if (!_isDisposed) {
          _unreadCountController.add(count);
        }

        return count;
      }

      return 0;
    } catch (e) {
      print('❌ Error fetching notification count: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      await _apiService.post('orders/notifications/$notificationId/read/', {});
      // Refresh count after marking as read
      _fetchUnreadCount();
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      print('🔔 Marking all notifications as read');
      await _apiService.post('orders/notifications/mark-all-read/', {});
      print('✅ All notifications marked as read');

      if (!_isDisposed) {
        _unreadCountController.add(0);
      }

      return true;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    print('🔔 Disposing notification service');
    _isDisposed = true;
    stopPolling();
    _unreadCountController.close();
  }
}