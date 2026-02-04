// lib/services/order_service.dart
import 'api_service.dart';
import '../models/order.dart';
import '../models/address.dart';

class OrderService {
  final ApiService _apiService = ApiService();
  
  // Place order
  Future<Order> placeOrder({
    required String addressId,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post('orders', {
        'address_id': addressId,
        'payment_method': paymentMethod,
        'notes': notes,
      });
      
      return Order.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }
  
  // Get user orders
  Future<List<Order>> getOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    try {
      String endpoint = 'orders?page=$page&per_page=$perPage';
      if (status != null) endpoint += '&status=$status';
      
      final response = await _apiService.get(endpoint);
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
  
  // Get order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get('orders/$orderId');
      return Order.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }
  
  // Cancel order
  Future<Order> cancelOrder(String orderId) async {
    try {
      final response = await _apiService.put('orders/$orderId/cancel', {});
      return Order.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
  
  // Track order
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    try {
      final response = await _apiService.get('orders/$orderId/track');
      return response['data'];
    } catch (e) {
      throw Exception('Failed to track order: $e');
    }
  }
}