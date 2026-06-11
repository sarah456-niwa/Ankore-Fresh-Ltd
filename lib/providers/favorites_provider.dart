import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final List<String> _favorites = [];
  bool _initialized = false;

  List<String> get favoriteIds => List.unmodifiable(_favorites);

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    _favorites.clear();
    _favorites.addAll(ids);
    _initialized = true;

    // If logged in, try to sync with backend favorites
    try {
      final api = ApiService();
      final server = await api.get('auth/favorites/');
      if (server is List) {
        final serverIds = server.map((e) => e['product_id'].toString()).toList();
        // Merge server favorites
        for (final id in serverIds) {
          if (!_favorites.contains(id)) _favorites.add(id);
        }
        await prefs.setStringList('favorites', _favorites);
      }
    } catch (_) {}

    notifyListeners();
  }

  Future<void> toggleFavorite(String productId) async {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();

    // Sync with backend if logged in
    try {
      final api = ApiService();
      // If now favorite, POST; otherwise DELETE
      if (_favorites.contains(productId)) {
        await api.post('auth/favorites/', {'product_id': productId});
      } else {
        await api.delete('auth/favorites/$productId/');
      }
    } catch (_) {}
  }

  bool isFavorite(String productId) {
    return _favorites.contains(productId);
  }

  Future<List<Product>> getFavoriteProducts() async {
    await init();
    final List<Product> products = [];
    for (final id in _favorites) {
      try {
        final p = await _productService.getProductById(id.split('_').first);
        products.add(p);
      } catch (_) {}
    }
    return products;
  }
}
