// lib/services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();
  
  // Get all orders for current user (both past and current)
  Future<List<Order>> getUserOrders() async {
    try {
      print('📦 Fetching user orders...');
      final response = await _apiService.get('orders/');
      
      print('✅ Orders response received');
      
      if (response is List) {
        print('📦 Found ${response.length} orders');
        return response.map((json) => Order.fromJson(json)).toList();
      }
      
      if (response != null && response['results'] is List) {
        final orders = response['results'] as List;
        print('📦 Found ${orders.length} orders');
        return orders.map((json) => Order.fromJson(json)).toList();
      }
      
      print('⚠️ No orders found');
      return [];
    } catch (e) {
      print('❌ Error fetching orders: $e');
      return [];
    }
  }
  
  // Get single order details
  Future<Order?> getOrderDetails(int orderId) async {
    try {
      print('📦 Fetching order details for ID: $orderId');
      final response = await _apiService.get('orders/$orderId/');
      print('✅ Order details received');
      return Order.fromJson(response);
    } catch (e) {
      print('❌ Error fetching order details: $e');
      return null;
    }
  }
  
  // Get order details by order number (with fallback)
  Future<Order?> getOrderByNumber(String orderNumber) async {
    try {
      print('📦 Fetching order by number: $orderNumber');
      final response = await _apiService.get('orders/track/$orderNumber/');
      print('✅ Order found via tracking endpoint');
      return Order.fromJson(response);
    } catch (e) {
      print('❌ Error fetching order by number from tracking: $e');
      
      // Fallback: Try to get from orders list
      try {
        final allOrders = await getUserOrders();
        final order = allOrders.firstWhere(
          (o) => o.orderNumber == orderNumber,
          orElse: () => throw Exception('Order not found'),
        );
        print('✅ Order found via orders list');
        return order;
      } catch (e2) {
        print('❌ Order not found: $e2');
        return null;
      }
    }
  }
  
  // Cancel order
  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      print('📦 Cancelling order: $orderId');
      final response = await _apiService.post('orders/${orderId}/cancel/', {
        'reason': reason ?? 'Cancelled by user',
      });
      print('✅ Order cancelled successfully');
      return response['message'] != null;
    } catch (e) {
      print('❌ Error cancelling order: $e');
      return false;
    }
  }
  
  // Track order status
  Future<Map<String, dynamic>> trackOrder(String orderNumber) async {
    try {
      print('📦 Tracking order: $orderNumber');
      final response = await _apiService.get('orders/track/$orderNumber/');
      print('✅ Tracking information received');
      return response;
    } catch (e) {
      print('❌ Error tracking order: $e');
      return {};
    }
  }
  
  // Place new order
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData) async {
    try {
      print('📦 Placing new order...');
      print('📦 Order data: $orderData');
      
      final response = await _apiService.post('orders/create/', orderData);
      
      print('✅ Order placed successfully');
      print('📦 Order number: ${response['order_number']}');
      print('📦 Order ID: ${response['id']}');
      
      return {
        'success': true,
        'order_number': response['order_number'],
        'order_id': response['id'],
        'message': 'Order placed successfully',
      };
    } catch (e) {
      print('❌ Error placing order: $e');
      return {
        'success': false,
        'message': 'Failed to place order: ${e.toString()}',
      };
    }
  }
  
  // Get order status history
  Future<List<Map<String, dynamic>>> getOrderStatusHistory(int orderId) async {
    try {
      print('📦 Fetching status history for order: $orderId');
      final response = await _apiService.get('orders/${orderId}/status/');
      
      if (response is List) {
        return response.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Error fetching status history: $e');
      return [];
    }
  }
  
  // Rate order (after delivery)
  Future<bool> rateOrder(int orderId, int rating, {String? feedback}) async {
    try {
      print('📦 Rating order: $orderId with rating: $rating');
      final response = await _apiService.post('orders/${orderId}/rate/', {
        'rating': rating,
        'feedback': feedback ?? '',
      });
      print('✅ Order rated successfully');
      return response['message'] != null;
    } catch (e) {
      print('❌ Error rating order: $e');
      return false;
    }
  }
  
  // Request order return/refund
  Future<bool> requestReturn(int orderId, String reason, {String? details}) async {
    try {
      print('📦 Requesting return for order: $orderId');
      final response = await _apiService.post('orders/${orderId}/return/', {
        'reason': reason,
        'details': details ?? '',
      });
      print('✅ Return request submitted');
      return response['message'] != null;
    } catch (e) {
      print('❌ Error requesting return: $e');
      return false;
    }
  }
  
  // Get order statistics for user
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      print('📦 Fetching order statistics...');
      final orders = await getUserOrders();
      
      int totalOrders = orders.length;
      int completedOrders = orders.where((o) => o.status == 'delivered').length;
      int pendingOrders = orders.where((o) => o.status == 'pending').length;
      int cancelledOrders = orders.where((o) => o.status == 'cancelled').length;
      double totalSpent = orders.fold(0.0, (sum, order) => sum + order.total);
      
      return {
        'total_orders': totalOrders,
        'completed_orders': completedOrders,
        'pending_orders': pendingOrders,
        'cancelled_orders': cancelledOrders,
        'total_spent': totalSpent,
      };
    } catch (e) {
      print('❌ Error fetching order statistics: $e');
      return {
        'total_orders': 0,
        'completed_orders': 0,
        'pending_orders': 0,
        'cancelled_orders': 0,
        'total_spent': 0.0,
      };
    }
  }
  
  // Get recent orders (last 5)
  Future<List<Order>> getRecentOrders() async {
    try {
      final allOrders = await getUserOrders();
      return allOrders.take(5).toList();
    } catch (e) {
      print('❌ Error fetching recent orders: $e');
      return [];
    }
  }
  
  // Check if order can be cancelled
  Future<bool> canCancelOrder(int orderId) async {
    try {
      final order = await getOrderDetails(orderId);
      return order?.canCancel ?? false;
    } catch (e) {
      print('❌ Error checking cancel status: $e');
      return false;
    }
  }
  
  // Reorder - add all items from previous order to cart
  Future<List<Map<String, dynamic>>> getReorderItems(int orderId) async {
    try {
      final order = await getOrderDetails(orderId);
      if (order == null) return [];
      
      final items = order.items.map((item) {
        return {
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'price': item.price,
        };
      }).toList();
      
      return items;
    } catch (e) {
      print('❌ Error getting reorder items: $e');
      return [];
    }
  }
}