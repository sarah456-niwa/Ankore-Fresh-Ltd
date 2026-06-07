// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    final notifications = await _notificationService.getUserNotifications();
    
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });

    // If there are unread notifications, mark them all as read immediately
    final unread = _notifications.where((n) => n['is_read'] == false).toList();
    if (unread.isNotEmpty) {
      await _notificationService.markAllAsRead();
      // Refresh list to reflect read status
      final refreshed = await _notificationService.getUserNotifications();
      if (mounted) {
        setState(() {
          _notifications = refreshed;
        });
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    await _notificationService.markAsRead(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No Notifications',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will see order updates here',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isRead = notification['is_read'] ?? false;
                    final createdAt = DateTime.parse(notification['created_at']);
                    
                    return Card(
                      elevation: isRead ? 0 : 2,
                      color: isRead ? null : Colors.green.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.notifications, color: Colors.white),
                        ),
                        title: Text(
                          notification['title'],
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notification['message']),
                        trailing: Text(
                          _formatTimeAgo(createdAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        onTap: () async {
                          if (!isRead) {
                            await _markAsRead(notification['id']);
                          }
                          final data = notification['data'];
                          if (data != null && data['order_id'] != null) {
                            final order = await _orderService.getOrderDetails(data['order_id']);
                            if (order != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailScreen(order: order),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}