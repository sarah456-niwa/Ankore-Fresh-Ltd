// screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Product> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _popularSearches = [
    'Fruits',
    'Vegetables',
    'Organic',
    'Fresh Juice',
    'Dairy',
    'Mangoes',
    'Bananas',
    'Avocados',
  ];
  
  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    setState(() {
      _recentSearches = ['Mangoes', 'Organic Vegetables', 'Fresh Juice', 'Bananas'];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
  }

  Future<void> _clearRecentSearches() async {
    setState(() {
      _recentSearches.clear();
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchQuery = query;
    });

    try {
      final results = await _productService.searchProducts(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      
      if (results.isNotEmpty) {
        _saveRecentSearch(query);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to search: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _searchQuery = '';
    });
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.search, color: Colors.green[800], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onSubmitted: _performSearch,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade600, size: 18),
                  onPressed: _clearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _performSearch(_searchController.text),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    if (_hasSearched) {
      return _buildSearchResults();
    }

    return _buildInitialState();
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
                TextButton(onPressed: _clearRecentSearches, child: const Text('Clear All')),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) => 
                Chip(
                  label: Text(search),
                  onDeleted: () => setState(() => _recentSearches.remove(search)),
                )
              ).toList(),
            ),
            const SizedBox(height: 30),
          ],
          Text('Popular Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade900)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) => 
              ActionChip(
                label: Text(search),
                onPressed: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              )
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No results found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Text('No products matching "$_searchQuery"', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(Icons.shopping_bag, size: 40, color: Colors.green[800]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_searchResults[index].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_searchResults[index].formattedPrice, style: TextStyle(color: Colors.green[800])),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}