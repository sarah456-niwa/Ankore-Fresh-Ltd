// lib/services/image_service.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageService {
  // Base URL for images (adjust based on your backend)
  static const String imageBaseUrl = 'http://ankolefresh.test/storage/';
  
  // Get full image URL
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    
    if (path.startsWith('http')) {
      return path;
    }
    
    return '$imageBaseUrl${path.startsWith('/') ? path.substring(1) : path}';
  }
  
  // Load network image with caching
  static Widget loadNetworkImage({
    required String? imageUrl,
    required BuildContext context,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
    Color? placeholderColor,
    BorderRadius? borderRadius,
  }) {
    final String url = getImageUrl(imageUrl);
    
    if (url.isEmpty) {
      return errorWidget ?? _buildErrorPlaceholder();
    }
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) =>
            placeholder ?? _buildShimmerPlaceholder(placeholderColor),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorPlaceholder(),
        memCacheHeight: 300,
        memCacheWidth: 300,
      ),
    );
  }
  
  // For product images
  static Widget productImage({
    required String? imageUrl,
    required BuildContext context,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    double aspectRatio = 1,
  }) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade100,
          borderRadius: borderRadius ??
              const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
        ),
        child: loadNetworkImage(
          imageUrl: imageUrl,
          context: context,
          fit: BoxFit.cover,
          borderRadius: borderRadius ??
              const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
          placeholder: Center(
            child: Icon(
              Icons.shopping_basket,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
  
  // Shimmer placeholder
  static Widget _buildShimmerPlaceholder([Color? color]) {
    return Container(
      color: color ?? Colors.grey.shade200,
    );
  }
  
  // Error placeholder
  static Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}