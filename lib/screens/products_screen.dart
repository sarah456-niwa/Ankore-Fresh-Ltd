import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/product_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'main_app_screen.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductsScreen({super.key, this.initialCategory});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Category> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    
    if (widget.initialCategory != null && widget.initialCategory != 'All') {
      _selectedCategory = widget.initialCategory!;
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final products = await _productService.getProducts();
      final categories = await _productService.getCategories();
      
      setState(() {
        _products = products;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isNotEmpty) {
      return _products
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Our Products',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fresh from the farm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade100,
                        ),
                      ),
                    ],
                  ),
                  Consumer<CartProvider>(
                    builder: (ctx, cart, child) {
                      return Row(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                onPressed: () {
                                  final mainAppScreen = context.findAncestorStateOfType<MainAppScreenState>();
                                  if (mainAppScreen != null) {
                                    mainAppScreen.changeTab(2);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CartScreen()),
                                    );
                                  }
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                              if (cart.totalQuantity > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${cart.totalQuantity}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 26,
                              ),
                              onPressed: _refreshData,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          _buildSearchBar(),
          _buildCategories(),
          _buildProductsCount(),
          
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.green[800],
              child: _isLoading
                  ? _buildLoadingGrid()
                  : _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : _buildProductsGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.green[800],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear,
                  color: Colors.grey.shade700,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final fruitsCount = _products.where((p) => p.category == 'Fruits').length;
    final vegetablesCount = _products.where((p) => p.category == 'Vegetables').length;
    final juiceCount = _products.where((p) => p.category == 'Fresh Juice').length;
    final organicCount = _products.where((p) => p.category == 'Organic').length;
    
    final allCategories = [
      Category(id: 'all', name: 'All', productCount: _products.length),
      Category(id: '1', name: 'Fruits', productCount: fruitsCount),
      Category(id: '2', name: 'Vegetables', productCount: vegetablesCount),
      Category(id: '3', name: 'Fresh Juice', productCount: juiceCount),
      Category(id: '4', name: 'Organic', productCount: organicCount),
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = _selectedCategory == category.name;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (category.productCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '(${category.productCount})',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
              selected: isSelected,
              backgroundColor: Colors.grey.shade100,
              selectedColor: _getCategoryColor(category.name),
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category.name;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              avatar: !isSelected && category.name != 'All' ? Icon(
                _getCategoryIcon(category.name),
                size: 14,
                color: _getCategoryColor(category.name),
              ) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsCount() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredProducts.length} products found',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = 'All';
                  _searchQuery = '';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      'Clear filters',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.close, size: 14, color: Colors.green[800]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Consumer<CartProvider>(
      builder: (ctx, cartProvider, child) {
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(product.category).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  _getCategoryIcon(product.category),
                                  size: 30,
                                  color: _getCategoryColor(product.category).withOpacity(0.8),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            _getCategoryIcon(product.category),
                            size: 30,
                            color: _getCategoryColor(product.category).withOpacity(0.8),
                          ),
                        ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.unit,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: product.availabilityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  product.stock > 0 ? 'In stock' : 'Out of stock',
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: product.availabilityColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
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
                                onPressed: () {
                                  print('➕ Adding to cart: ${product.name}');
                                  cartProvider.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} added to cart'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            )
                          else
                            Container(
                              width: 60,
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
                                        (item) => item.product.id == product.id,
                                        orElse: () => CartItem(
                                          id: '',
                                          product: product,
                                          quantity: 0,
                                          priceAtAdd: product.price,
                                        ),
                                      );
                                      if (item.id.isNotEmpty) {
                                        if (quantity > 1) {
                                          cartProvider.updateQuantity(item.id, quantity - 1);
                                        } else {
                                          cartProvider.removeItem(item.id);
                                        }
                                      }
                                    },
                                    child: Icon(
                                      Icons.remove,
                                      size: 12,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  Text(
                                    quantity.toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      final item = cartProvider.items.firstWhere(
                                        (item) => item.product.id == product.id,
                                        orElse: () => CartItem(
                                          id: '',
                                          product: product,
                                          quantity: 0,
                                          priceAtAdd: product.price,
                                        ),
                                      );
                                      if (item.id.isNotEmpty) {
                                        cartProvider.updateQuantity(item.id, quantity + 1);
                                      } else {
                                        cartProvider.addToCart(product);
                                      }
                                    },
                                    child: Icon(
                                      Icons.add,
                                      size: 12,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.only(bottom: 4),
                    ),
                    Container(
                      height: 10,
                      width: 50,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 40,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 14,
                          width: 60,
                          color: Colors.grey.shade200,
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 70,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No products found for "$_searchQuery"'
                    : _selectedCategory == 'All'
                        ? 'No products available'
                        : 'No products in $_selectedCategory category',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try a different search term'
                    : 'Check back later for new arrivals',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                const SizedBox(height: 16),
              if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _searchQuery = '';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Show All Products'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'fruit':
        return Colors.orange.shade600;
      case 'vegetables':
      case 'vegetable':
        return Colors.green.shade600;
      case 'organic':
        return Colors.purple.shade600;
      case 'fresh juice':
      case 'juice':
      case 'drinks':
        return Colors.blue.shade600;
      case 'dairy':
      case 'milk':
      case 'cheese':
        return Colors.brown.shade600;
      case 'meat':
      case 'poultry':
        return Colors.red.shade600;
      default:
        return Colors.green.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
      case 'fruit':
        return Icons.apple;
      case 'vegetables':
      case 'vegetable':
        return Icons.eco;
      case 'organic':
        return Icons.spa;
      case 'fresh juice':
      case 'juice':
      case 'drinks':
        return Icons.local_drink;
      case 'dairy':
      case 'milk':
        return Icons.local_cafe;
      case 'meat':
      case 'poultry':
        return Icons.set_meal;
      default:
        return Icons.shopping_basket;
    }
  }
}