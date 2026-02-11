// services/search_service.dart
import 'dart:async';
import '../models/product.dart';
import 'product_service.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final ProductService _productService = ProductService();
  
  final _searchResultsController = StreamController<List<Product>>.broadcast();
  Stream<List<Product>> get searchResults => _searchResultsController.stream;
  
  final _searchQueryController = StreamController<String>.broadcast();
  Stream<String> get searchQuery => _searchQueryController.stream;
  
  List<Product> _currentResults = [];
  String _currentQuery = '';
  
  List<Product> get currentResults => _currentResults;
  String get currentQuery => _currentQuery;
  
  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  Future<void> search(String query) async {
    _currentQuery = query;
    _searchQueryController.add(query);
    
    if (query.trim().isEmpty) {
      _currentResults = [];
      _searchResultsController.add([]);
      return;
    }

    try {
      final results = await _productService.searchProducts(query);
      _currentResults = results;
      _searchResultsController.add(results);
      
      if (results.isNotEmpty) {
        _addToRecentSearches(query);
      }
    } catch (e) {
      print('Search error: $e');
      _currentResults = [];
      _searchResultsController.add([]);
    }
  }

  void _addToRecentSearches(String query) {
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
  }

  void clearRecentSearches() {
    _recentSearches.clear();
  }

  void clearSearch() {
    _currentQuery = '';
    _currentResults = [];
    _searchQueryController.add('');
    _searchResultsController.add([]);
  }

  void dispose() {
    _searchResultsController.close();
    _searchQueryController.close();
  }
}