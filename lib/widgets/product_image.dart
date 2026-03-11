import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final double height;
  final double width;
  final BoxFit fit;

  const ProductImage({
    super.key,
    this.imageUrl,
    required this.category,
    this.height = 90,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // If imageUrl is provided and not empty, try to load it
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Image.asset(
            imageUrl!,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              // Show fallback icon if image fails to load
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 30,
                      color: _getCategoryColor(category),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.length > 8
                            ? '${category.substring(0, 7)}...'
                            : category,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Show fallback icon if no image URL
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: _getCategoryColor(category).withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 30,
                color: _getCategoryColor(category),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category.length > 8
                      ? '${category.substring(0, 7)}...'
                      : category,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Colors.orange.shade600;
      case 'vegetables':
        return Colors.green.shade600;
      case 'organic':
        return Colors.purple.shade600;
      case 'fresh juice':
      case 'juice':
        return Colors.blue.shade600;
      case 'dairy':
        return Colors.brown.shade600;
      default:
        return Colors.green.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'vegetables':
        return Icons.eco;
      case 'organic':
        return Icons.spa;
      case 'fresh juice':
      case 'juice':
        return Icons.local_drink;
      case 'dairy':
        return Icons.local_cafe;
      default:
        return Icons.shopping_basket;
    }
  }
}