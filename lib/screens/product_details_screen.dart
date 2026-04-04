import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'main_app_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final ProductService _productService = ProductService();
  List<Product> _relatedProducts = [];
  bool _isLoadingRelated = true;
  int _quantity = 1;
  int _selectedVariantIndex = 0;
  
  late List<ProductVariant> _variants;

  @override
  void initState() {
    super.initState();
    _loadRelatedProducts();
    _initializeVariants();
  }

  void _initializeVariants() {
    _variants = _getProductVariants(widget.product);
  }

  List<ProductVariant> _getProductVariants(Product product) {
    // FRUITS VARIANTS
    if (product.category == 'Fruits') {
      if (product.name.contains('Mango')) {
        return [
          ProductVariant(id: '${product.id}_premium', type: 'Premium Grade', description: 'Largest size, sweetest variety, perfect for gifts', price: product.price * 1.5, unit: product.unit, stock: 20),
          ProductVariant(id: '${product.id}_standard', type: 'Standard Grade', description: 'Medium size, great for eating fresh', price: product.price, unit: product.unit, stock: 50),
          ProductVariant(id: '${product.id}_economy', type: 'Economy Grade', description: 'Smaller size, perfect for juicing and cooking', price: product.price * 0.7, unit: product.unit, stock: 30),
        ];
      } else if (product.name.contains('Passion')) {
        return [
          ProductVariant(id: '${product.id}_premium', type: 'Premium Grade', description: 'Large, juicy passion fruits with high pulp content', price: product.price * 1.3, unit: product.unit, stock: 25),
          ProductVariant(id: '${product.id}_standard', type: 'Standard Grade', description: 'Medium-sized, perfect for fresh eating', price: product.price, unit: product.unit, stock: 40),
        ];
      } else if (product.name.contains('Banana')) {
        return [
          ProductVariant(id: '${product.id}_ripe', type: 'Ripe Bananas', description: 'Ready to eat, sweet and soft', price: product.price, unit: product.unit, stock: 50),
          ProductVariant(id: '${product.id}_green', type: 'Green Bananas', description: 'Perfect for cooking, not yet ripe', price: product.price * 0.8, unit: product.unit, stock: 30),
          ProductVariant(id: '${product.id}_dried', type: 'Dried Bananas', description: 'Sun-dried, sweet snack', price: product.price * 2.5, unit: 'per pack', stock: 15),
        ];
      } else {
        return [
          ProductVariant(id: '${product.id}_premium', type: 'Premium Grade', description: 'Best quality, carefully selected', price: product.price * 1.25, unit: product.unit, stock: 20),
          ProductVariant(id: '${product.id}_standard', type: 'Standard Grade', description: 'Good quality, great value', price: product.price, unit: product.unit, stock: 50),
        ];
      }
    }
    // VEGETABLES VARIANTS
    else if (product.category == 'Vegetables') {
      if (product.name.contains('Dodo') || product.name.contains('Sukuma') || product.name.contains('Nakati') || product.name.contains('Jobyo') || product.name.contains('Spinach')) {
        return [
          ProductVariant(id: '${product.id}_fresh', type: 'Fresh Bunch', description: 'Freshly harvested, traditional bunch', price: product.price, unit: 'per bunch', stock: 40),
          ProductVariant(id: '${product.id}_washed', type: 'Pre-washed & Cut', description: 'Washed, cut, and ready to cook', price: product.price * 1.5, unit: 'per pack', stock: 25),
          ProductVariant(id: '${product.id}_organic', type: 'Organic', description: 'Certified organic, no pesticides', price: product.price * 1.8, unit: 'per bunch', stock: 15),
        ];
      } else if (product.name.contains('Carrot')) {
        return [
          ProductVariant(id: '${product.id}_baby', type: 'Baby Carrots', description: 'Small, tender, perfect for salads', price: product.price * 1.2, unit: 'per kg', stock: 25),
          ProductVariant(id: '${product.id}_standard', type: 'Standard Carrots', description: 'Medium-sized, all-purpose', price: product.price, unit: 'per kg', stock: 50),
          ProductVariant(id: '${product.id}_large', type: 'Large Carrots', description: 'Great for juicing and stews', price: product.price * 1.1, unit: 'per kg', stock: 30),
        ];
      } else if (product.name.contains('Potato')) {
        return [
          ProductVariant(id: '${product.id}_small', type: 'Small Size', description: 'Perfect for roasting and soups', price: product.price * 0.8, unit: 'per kg', stock: 40),
          ProductVariant(id: '${product.id}_medium', type: 'Medium Size', description: 'All-purpose, good for most dishes', price: product.price, unit: 'per kg', stock: 60),
          ProductVariant(id: '${product.id}_large', type: 'Large Size', description: 'Great for baking and mashing', price: product.price * 1.2, unit: 'per kg', stock: 35),
        ];
      } else if (product.name.contains('Onion')) {
        return [
          ProductVariant(id: '${product.id}_red', type: 'Red Onions', description: 'Strong flavor, great for cooking', price: product.price, unit: 'per kg', stock: 45),
          ProductVariant(id: '${product.id}_white', type: 'White Onions', description: 'Milder flavor, good for salads', price: product.price * 0.9, unit: 'per kg', stock: 30),
          ProductVariant(id: '${product.id}_spring', type: 'Spring Onions', description: 'Fresh green onions with mild flavor', price: product.price * 1.3, unit: 'per bunch', stock: 20),
        ];
      } else {
        return [
          ProductVariant(id: '${product.id}_standard', type: 'Standard', description: 'Regular quality, good value', price: product.price, unit: product.unit, stock: 40),
          ProductVariant(id: '${product.id}_premium', type: 'Premium', description: 'Best quality, carefully selected', price: product.price * 1.25, unit: product.unit, stock: 20),
        ];
      }
    }
    // FRESH JUICE VARIANTS
    else if (product.category == 'Fresh Juice') {
      return [
        ProductVariant(id: '${product.id}_250ml', type: '250ml Bottle', description: 'Single serving, perfect for on-the-go', price: product.price * 0.5, unit: '250ml bottle', stock: 50),
        ProductVariant(id: '${product.id}_500ml', type: '500ml Bottle', description: 'Standard size, great for one person', price: product.price, unit: '500ml bottle', stock: 40),
        ProductVariant(id: '${product.id}_1l', type: '1 Liter Bottle', description: 'Family size, best value', price: product.price * 1.8, unit: '1L bottle', stock: 25),
        ProductVariant(id: '${product.id}_fresh', type: 'Fresh Pressed', description: 'Made to order, extra fresh', price: product.price * 1.3, unit: '500ml bottle', stock: 15),
      ];
    }
    else if (product.category == 'Organic') {
      return [ProductVariant(id: '${product.id}_standard', type: 'Certified Organic', description: '100% organic, no pesticides', price: product.price, unit: product.unit, stock: 0)];
    }
    return [
      ProductVariant(id: '${product.id}_standard', type: 'Standard', description: 'Regular quality', price: product.price, unit: product.unit, stock: product.stock),
      ProductVariant(id: '${product.id}_premium', type: 'Premium', description: 'Best quality', price: product.price * 1.2, unit: product.unit, stock: product.stock ~/ 2),
    ];
  }

  Future<void> _loadRelatedProducts() async {
    setState(() => _isLoadingRelated = true);
    try {
      final allProducts = await _productService.getProducts();
      final related = allProducts.where((p) => p.category == widget.product.category && p.id != widget.product.id).take(6).toList();
      setState(() {
        _relatedProducts = related;
        _isLoadingRelated = false;
      });
    } catch (e) {
      print('Error loading related products: $e');
      setState(() => _isLoadingRelated = false);
    }
  }

  void _addToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final selectedVariant = _variants[_selectedVariantIndex];
    
    // Create a product copy with the selected variant price and info
    final productWithVariant = Product(
      id: selectedVariant.id,
      name: '${widget.product.name} (${selectedVariant.type})',
      description: selectedVariant.description,
      price: selectedVariant.price,
      unit: selectedVariant.unit,
      category: widget.product.category,
      imageUrl: widget.product.imageUrl,
      stock: selectedVariant.stock,
      rating: widget.product.rating,
      isOrganic: widget.product.isOrganic,
    );
    
    // Add to cart with quantity
    for (int i = 0; i < _quantity; i++) {
      cartProvider.addToCart(productWithVariant);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('${widget.product.name} (${selectedVariant.type}) x$_quantity added to cart', style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            final mainAppScreen = context.findAncestorStateOfType<MainAppScreenState>();
            if (mainAppScreen != null) {
              mainAppScreen.changeTab(2);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedVariant = _variants[_selectedVariantIndex];
    final currentPrice = selectedVariant.price;
    final totalPrice = currentPrice * _quantity;
    final maxStock = selectedVariant.stock;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.green[800],
            foregroundColor: Colors.white,
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to wishlist'), backgroundColor: Colors.green))),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {
                final mainAppScreen = context.findAncestorStateOfType<MainAppScreenState>();
                if (mainAppScreen != null) mainAppScreen.changeTab(2);
                else Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
              }),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                      ? Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: _getCategoryColor(widget.product.category).withOpacity(0.1),
                            child: Center(child: Icon(_getCategoryIcon(widget.product.category), size: 80, color: _getCategoryColor(widget.product.category).withOpacity(0.5))),
                          ),
                        )
                      : Container(
                          color: _getCategoryColor(widget.product.category).withOpacity(0.1),
                          child: Center(child: Icon(_getCategoryIcon(widget.product.category), size: 80, color: _getCategoryColor(widget.product.category).withOpacity(0.5))),
                        ),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
                  Positioned(
                    bottom: 20, left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: _getCategoryColor(widget.product.category), borderRadius: BorderRadius.circular(20)),
                      child: Text(widget.product.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(widget.product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: Text(selectedVariant.unit, style: TextStyle(color: Colors.grey.shade700, fontSize: 12))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: (maxStock > 0 ? Colors.green : Colors.red).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(maxStock > 0 ? Icons.check_circle : Icons.cancel, size: 12, color: maxStock > 0 ? Colors.green : Colors.red),
                          const SizedBox(width: 4),
                          Text(maxStock > 0 ? (maxStock > 10 ? 'In Stock' : 'Low Stock ($maxStock left)') : 'Out of Stock', style: TextStyle(color: maxStock > 0 ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6)), child: Row(children: [Icon(Icons.star, size: 16, color: Colors.amber.shade700), const SizedBox(width: 4), Text(widget.product.rating.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800))])),
                    const SizedBox(width: 8),
                    if (widget.product.isOrganic) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)), child: Row(children: [Icon(Icons.eco, size: 16, color: Colors.green.shade700), const SizedBox(width: 4), Text('Organic', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500))])),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.product.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
                const SizedBox(height: 24),
                if (_variants.length > 1) ...[
                  const Text('Available Varieties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...List.generate(_variants.length, (index) {
                    final variant = _variants[index];
                    final isSelected = _selectedVariantIndex == index;
                    return GestureDetector(
                      onTap: variant.stock > 0 ? () => setState(() { _selectedVariantIndex = index; _quantity = 1; }) : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: isSelected ? Colors.green.shade50 : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? Colors.green.shade400 : Colors.grey.shade300, width: isSelected ? 2 : 1)),
                        child: Row(
                          children: [
                            Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? Colors.green.shade600 : Colors.grey.shade400, width: 2)), child: isSelected ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))) : null),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [Text(variant.type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? Colors.green.shade800 : Colors.black87)), if (variant.stock <= 0) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)), child: Text('Out of Stock', style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold))) else if (variant.stock < 5) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)), child: Text('Only ${variant.stock} left', style: TextStyle(fontSize: 10, color: Colors.orange.shade700, fontWeight: FontWeight.w500)))]),
                                  const SizedBox(height: 2),
                                  Text(variant.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(height: 4),
                                  Row(children: [Text('UGX ${variant.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade800)), const SizedBox(width: 8), Text('/ ${variant.unit}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600))]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(children: [IconButton(icon: const Icon(Icons.remove), onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null), Container(width: 40, alignment: Alignment.center, child: Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.add), onPressed: _quantity < maxStock ? () => setState(() => _quantity++) : null)])),
                    const SizedBox(width: 16),
                    Expanded(child: Text(maxStock > 0 ? '$maxStock available' : 'Out of stock', style: TextStyle(color: maxStock > 0 ? Colors.grey.shade600 : Colors.red, fontSize: 14, fontWeight: maxStock > 0 ? FontWeight.normal : FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Price per unit:', style: TextStyle(fontSize: 14, color: Colors.grey)), Text('UGX ${currentPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('UGX ${totalPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade800))]),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: maxStock > 0 ? () => _addToCart(context) : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(maxStock > 0 ? Icons.add_shopping_cart : Icons.shopping_cart, size: 20), const SizedBox(width: 8), Text(maxStock > 0 ? 'Add to Cart' : 'Out of Stock', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (_relatedProducts.isNotEmpty) ...[
                  const Text('You might also like', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_isLoadingRelated) const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.green)))
                  else SizedBox(height: 220, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: _relatedProducts.length, itemBuilder: (context, index) => _buildRelatedProductCard(_relatedProducts[index]))),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product))),
      child: Container(
        width: 150, margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: _getCategoryColor(product.category).withOpacity(0.1),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Center(child: Icon(_getCategoryIcon(product.category), size: 30, color: _getCategoryColor(product.category).withOpacity(0.5))))
                        : Center(child: Icon(_getCategoryIcon(product.category), size: 30, color: _getCategoryColor(product.category).withOpacity(0.5))),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis), Text(product.formattedPrice, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800))]),
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
      case 'fruits': return Colors.orange.shade600;
      case 'vegetables': return Colors.green.shade600;
      case 'organic': return Colors.purple.shade600;
      case 'fresh juice': case 'juice': return Colors.blue.shade600;
      case 'dairy': return Colors.brown.shade600;
      default: return Colors.green.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits': return Icons.apple;
      case 'vegetables': return Icons.eco;
      case 'organic': return Icons.spa;
      case 'fresh juice': case 'juice': return Icons.local_drink;
      case 'dairy': return Icons.local_cafe;
      default: return Icons.shopping_basket;
    }
  }
}

class ProductVariant {
  final String id; final String type; final String description; final double price; final String unit; final int stock;
  ProductVariant({required this.id, required this.type, required this.description, required this.price, required this.unit, required this.stock});
}