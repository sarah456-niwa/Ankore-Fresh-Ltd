// lib/services/notification_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

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

  Future<bool> markAsRead(int notificationId) async {
    try {
      await _apiService.post('orders/notifications/$notificationId/read/', {});
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}