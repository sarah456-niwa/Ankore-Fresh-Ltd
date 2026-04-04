// lib/models/cart_item.dart
import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;
  final double priceAtAdd;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.priceAtAdd,
  });

  double get totalPrice => priceAtAdd * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'quantity': quantity,
      'price_at_add': priceAtAdd,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      priceAtAdd: (json['price_at_add'] ?? 0).toDouble(),
    );
  }
}