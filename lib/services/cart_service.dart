// lib/services/cart_service.dart
import 'api_service.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  final ApiService _apiService = ApiService();
  
  // Get cart items
  Future<List<CartItem>> getCartItems() async {
    try {
      final response = await _apiService.get('cart/');
      
      // Django returns items in 'items' array, not 'data'
      if (response['items'] is List) {
        return (response['items'] as List)
            .map((json) => CartItem.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Failed to load cart: $e');
      return []; // Return empty list instead of throwing
    }
  }
  
  // Add item to cart
  Future<CartItem> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.post('cart/add/', {
        'product_id': productId,
        'quantity': quantity,
      });
      
      // Django returns the updated cart with the new item
      // The item is in the 'items' list or directly in response
      if (response['items'] != null) {
        // Find the newly added item
        final items = response['items'] as List;
        if (items.isNotEmpty) {
          // Return the last added item or find by product
          final addedItem = items.firstWhere(
            (item) => item['product'] == productId,
            orElse: () => items.last,
          );
          return CartItem.fromJson(addedItem);
        }
      }
      
      throw Exception('Failed to add to cart: No item returned');
    } catch (e) {
      throw Exception('Failed to add to cart: ${e.toString()}');
    }
  }
  
  // Update cart item quantity
  Future<CartItem> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _apiService.put('cart/update/$cartItemId/', {
        'quantity': quantity,
      });
      
      if (response['item'] != null) {
        return CartItem.fromJson(response['item']);
      }
      
      throw Exception('Failed to update cart: No item returned');
    } catch (e) {
      throw Exception('Failed to update cart: ${e.toString()}');
    }
  }
  
  // Remove item from cart
  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _apiService.delete('cart/remove/$cartItemId/');
    } catch (e) {
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }
  
  // Clear cart
  Future<void> clearCart() async {
    try {
      await _apiService.delete('cart/clear/');
    } catch (e) {
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }
  
  // Get cart total (from the cart endpoint)
  Future<double> getCartTotal() async {
    try {
      final response = await _apiService.get('cart/');
      return (response['total_amount'] as num).toDouble();
    } catch (e) {
      return 0.0;
    }
  }
  
  // Get cart count (number of items in cart)
  Future<int> getCartCount() async {
    try {
      final response = await _apiService.get('cart/');
      return response['total_items'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  // Get total quantity (sum of all item quantities)
  Future<int> getTotalQuantity() async {
    try {
      final response = await _apiService.get('cart/');
      return response['total_quantity'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}