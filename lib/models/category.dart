// models/category.dart
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int productCount;
  
  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.productCount = 0,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      productCount: (json['products_count'] as num?)?.toInt() ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'products_count': productCount,
    };
  }
  
  // Helper methods
  IconData get icon {
    switch (name.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'vegetables':
        return Icons.eco;
      case 'fresh juice':
        return Icons.local_drink;
      case 'organic':
        return Icons.spa;
      case 'dairy':
        return Icons.local_cafe;
      default:
        return Icons.category;
    }
  }
  
  Color get color {
    switch (name.toLowerCase()) {
      case 'fruits':
        return Colors.orange;
      case 'vegetables':
        return Colors.green;
      case 'fresh juice':
        return Colors.blue;
      case 'organic':
        return Colors.purple;
      case 'dairy':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}