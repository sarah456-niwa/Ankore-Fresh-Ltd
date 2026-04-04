// lib/models/product.dart
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit;
  final String category;
  final String? imageUrl;
  final double rating;
  final int stock;
  final bool isOrganic;
  final bool isFeatured;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.category,
    this.imageUrl,
    this.rating = 0.0,
    this.stock = 0,
    this.isOrganic = false,
    this.isFeatured = false,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper to parse price from string or number
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    // Helper to parse rating from string or number
    double parseRating(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    // Helper to parse stock from string or number
    int parseStock(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parsePrice(json['price']),
      unit: json['unit'] ?? '',
      category: json['category_name'] ?? json['category'] ?? '',
      imageUrl: json['image'] ?? json['image_url'] ?? json['imageUrl'],
      rating: parseRating(json['rating']),
      stock: parseStock(json['stock']),
      isOrganic: json['is_organic'] ?? false,
      isFeatured: json['is_featured'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'category': category,
      'image_url': imageUrl,
      'rating': rating,
      'stock': stock,
      'is_organic': isOrganic,
      'is_featured': isFeatured,
    };
  }
  
  // Helper methods
  String get formattedPrice => 'UGX ${price.toStringAsFixed(0)}';
  
  bool get isAvailable => stock > 0;
  
  String get availabilityText {
    if (stock > 10) return 'In Stock';
    if (stock > 0) return 'Low Stock ($stock left)';
    return 'Out of Stock';
  }
  
  Color get availabilityColor {
    if (stock > 10) return Colors.green;
    if (stock > 0) return Colors.orange;
    return Colors.red;
  }
}