import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  int get itemCount => _items.length;
  
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  
  void addToCart(Product product, {int quantity = 1}) {
    print('🛒 Adding to cart: ${product.name}');
    
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
      print('📦 Updated quantity for ${product.name}: ${_items[existingIndex].quantity}');
    } else {
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        priceAtAdd: product.price,
      ));
      print('✅ Added new item: ${product.name}');
    }
    
    print('📊 Cart now has ${_items.length} items');
    notifyListeners();
  }
  
  void updateQuantity(String itemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
        print('🗑️ Removed item from cart');
      } else {
        _items[index].quantity = newQuantity;
        print('📦 Updated quantity to: $newQuantity');
      }
      notifyListeners();
    }
  }
  
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    print('🗑️ Item removed from cart');
    notifyListeners();
  }
  
  void clearCart() {
    _items.clear();
    print('🧹 Cart cleared');
    notifyListeners();
  }
  
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }
  
  int getQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      return _items[index].quantity;
    }
    return 0;
  }
}