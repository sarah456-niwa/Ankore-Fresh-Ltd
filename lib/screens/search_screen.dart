import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialSearch;

  const SearchScreen({super.key, this.initialSearch});

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
    'Mangoes',
    'Bananas',
    'Avocados',
    'Tomatoes',
  ];
  
  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      _searchController.text = widget.initialSearch!;
      _performSearch(widget.initialSearch!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    setState(() {
      _recentSearches = ['Mangoes', 'Tomatoes', 'Fresh Juice', 'Bananas'];
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

  void _onSearchChanged(String query) {}

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _searchResults = [];
      _searchQuery = '';
    });
    _searchFocusNode.requestFocus();
  }

  void _searchRecent(String term) {
    _searchController.text = term;
    _performSearch(term);
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
                  onChanged: _onSearchChanged,
                  onSubmitted: _performSearch,
                  decoration: InputDecoration(
                    hintText: 'Search fruits, vegetables, juice...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  textInputAction: TextInputAction.search,
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
            child: const Text('Search', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Type something (e.g., "mango", "tomato", "juice") or tap on popular searches below',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
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
                InputChip(
                  label: Text(search),
                  onDeleted: () => setState(() => _recentSearches.remove(search)),
                  deleteIconColor: Colors.red,
                  onPressed: () => _searchRecent(search),
                ),
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
                backgroundColor: Colors.green.shade50,
                labelStyle: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'No products matching "$_searchQuery"',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _clearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<CartProvider>(
      builder: (ctx, cartProvider, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_searchResults.length} product${_searchResults.length > 1 ? 's' : ''} found',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  final quantity = cartProvider.getQuantity(product.id);
                  final isInCart = quantity > 0;
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(product.category).withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Icon(
                                              _getCategoryIcon(product.category),
                                              size: 40,
                                              color: _getCategoryColor(product.category),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        _getCategoryIcon(product.category),
                                        size: 40,
                                        color: _getCategoryColor(product.category),
                                      ),
                                    ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    product.unit,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.formattedPrice,
                                        style: TextStyle(
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (!isInCart)
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.green[800],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                            onPressed: () {
                                              cartProvider.addToCart(product);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${product.name} added to cart'),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                            padding: EdgeInsets.zero,
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 50,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.green.shade200),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  final item = cartProvider.items.firstWhere(
                                                    (item) => item.product.id == product.id
                                                  );
                                                  if (quantity > 1) {
                                                    cartProvider.updateQuantity(item.id, quantity - 1);
                                                  } else {
                                                    cartProvider.removeItem(item.id);
                                                  }
                                                },
                                                child: Icon(Icons.remove, size: 12, color: Colors.green[800]),
                                              ),
                                              Text(
                                                quantity.toString(),
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[800]),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  final item = cartProvider.items.firstWhere(
                                                    (item) => item.product.id == product.id
                                                  );
                                                  if (quantity < product.stock) {
                                                    cartProvider.updateQuantity(item.id, quantity + 1);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Out of stock'), backgroundColor: Colors.red),
                                                    );
                                                  }
                                                },
                                                child: Icon(Icons.add, size: 12, color: Colors.green[800]),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
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
      default:
        return Icons.shopping_basket;
    }
  }
}