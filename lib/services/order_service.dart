// lib/services/order_service.dart
import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  final ApiService _apiService = ApiService();
  
  // Place order
  Future<Map<String, dynamic>> placeOrder({
    required String deliveryAddress,
    required String deliveryPhone,
    required String paymentMethod,
    String? deliveryInstructions,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post('orders/create/', {
        'delivery_address': deliveryAddress,
        'delivery_phone': deliveryPhone,
        'payment_method': paymentMethod,
        'delivery_instructions': deliveryInstructions ?? '',
        'notes': notes ?? '',
      });
      
      return response;
    } catch (e) {
      throw Exception('Failed to place order: ${e.toString()}');
    }
  }
  
  // Get user orders
  Future<List<Map<String, dynamic>>> getOrders({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    try {
      String endpoint = 'orders/?page=$page&per_page=$perPage';
      if (status != null && status.isNotEmpty) {
        endpoint += '&status=$status';
      }
      
      final response = await _apiService.get(endpoint);
      
      if (response['results'] is List) {
        return List<Map<String, dynamic>>.from(response['results']);
      }
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load orders: ${e.toString()}');
    }
  }
  
  // Get order by ID
  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      final response = await _apiService.get('orders/$orderId/');
      return response;
    } catch (e) {
      throw Exception('Failed to load order: ${e.toString()}');
    }
  }
  
  // Get order by order number (for tracking)
  Future<Map<String, dynamic>> getOrderByNumber(String orderNumber) async {
    try {
      final response = await _apiService.get('orders/track/$orderNumber/');
      return response;
    } catch (e) {
      throw Exception('Failed to track order: ${e.toString()}');
    }
  }
  
  // Cancel order
  Future<Map<String, dynamic>> cancelOrder(int orderId, {String? reason}) async {
    try {
      final response = await _apiService.post('orders/$orderId/cancel/', {
        'reason': reason ?? 'Cancelled by user',
      });
      return response;
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }
  
  // Track order
  Future<Map<String, dynamic>> trackOrder(String orderNumber) async {
    try {
      final response = await _apiService.get('orders/track/$orderNumber/');
      return response;
    } catch (e) {
      throw Exception('Failed to track order: ${e.toString()}');
    }
  }
  
  // Rate order
  Future<Map<String, dynamic>> rateOrder({
    required int orderId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final response = await _apiService.post('orders/$orderId/rate/', {
        'rating': rating,
        'feedback': feedback ?? '',
      });
      return response;
    } catch (e) {
      throw Exception('Failed to rate order: ${e.toString()}');
    }
  }
}