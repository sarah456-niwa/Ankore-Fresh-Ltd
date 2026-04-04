// lib/services/product_service.dart
import 'api_service.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  final ApiService _apiService = ApiService();
  
  // Get all products
  Future<List<Product>> getProducts() async {
    try {
      print('🔍 getProducts() called - Fetching from API...');
      final response = await _apiService.get('products/');
      print('✅ API Response received');
      print('Response type: ${response.runtimeType}');
      
      if (response is List) {
        print('📦 Response is List with ${response.length} items');
        return (response as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
      
      if (response['results'] is List) {
        final results = response['results'] as List;
        print('📦 Response has results with ${results.length} items');
        return results
            .map((json) => Product.fromJson(json))
            .toList();
      }
      
      print('⚠️ No products found in response');
      return [];
    } catch (e) {
      print('❌ Error loading products: $e');
      return [];
    }
  }
  
  // Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      print('🔍 getFeaturedProducts() called...');
      final response = await _apiService.get('products/?is_featured=true');
      print('✅ Featured products response received');
      
      if (response['results'] is List) {
        final results = response['results'] as List;
        print('📦 Featured products: ${results.length} items');
        return results
            .map((json) => Product.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Error loading featured products: $e');
      return [];
    }
  }
  
  // Get product by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiService.get('products/$id/');
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }
  
  // Get categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get('products/categories/');
      
      if (response is List) {
        return (response as List)
            .map((json) => Category.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading categories: $e');
      return [];
    }
  }
  
  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _apiService.get('products/?search=$query');
      
      if (response['results'] is List) {
        return (response['results'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}