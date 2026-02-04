// lib/services/cart_service.dart
import 'api_service.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  final ApiService _apiService = ApiService();
  
  // Get cart items
  Future<List<CartItem>> getCartItems() async {
    try {
      final response = await _apiService.get('cart');
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => CartItem.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }
  
  // Add item to cart
  Future<CartItem> addToCart({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post('cart', {
        'product_id': productId,
        'quantity': quantity,
        'notes': notes,
      });
      
      return CartItem.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }
  
  // Update cart item quantity
  Future<CartItem> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.put('cart/$cartItemId', {
        'quantity': quantity,
      });
      
      return CartItem.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }
  
  // Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _apiService.delete('cart/$cartItemId');
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }
  
  // Clear cart
  Future<void> clearCart() async {
    try {
      await _apiService.delete('cart/clear');
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
  
  // Get cart total
  Future<double> getCartTotal() async {
    try {
      final response = await _apiService.get('cart/total');
      return (response['total'] as num).toDouble();
    } catch (e) {
      throw Exception('Failed to get cart total: $e');
    }
  }
  
  // Get cart count
  Future<int> getCartCount() async {
    try {
      final response = await _apiService.get('cart/count');
      return (response['count'] as num).toInt();
    } catch (e) {
      throw Exception('Failed to get cart count: $e');
    }
  }
}