// services/product_service.dart
import '../models/product.dart';
import '../models/category.dart';

class ProductService {
  
  // Get featured products (mock data)
  Future<List<Product>> getFeaturedProducts() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Generate mock products
    return List.generate(12, (index) {
      final categories = ['Fruits', 'Vegetables', 'Organic', 'Fresh Juice'];
      final names = [
        'Fresh Mangoes',
        'Ripe Bananas',
        'Sweet Pineapples',
        'Hass Avocados',
        'Juicy Tomatoes',
        'Red Onions',
        'Green Peppers',
        'Carrots',
        'Watermelons',
        'Oranges',
        'Passion Fruits',
        'Pawpaws',
      ];
      final units = ['per kg', 'per bunch', 'each', 'per piece'];
      
      return Product(
        id: (index + 1).toString(),
        name: names[index % names.length],
        description: 'Fresh and organic ${names[index % names.length].toLowerCase()} delivered daily',
        price: 1000 + (index * 500).toDouble(),
        unit: units[index % units.length],
        category: categories[index % categories.length],
        imageUrl: '',
        rating: 3.5 + (index % 5 * 0.3),
        stock: 10 + (index % 20),
        isOrganic: index % 3 == 0,
        isFeatured: index % 4 == 0,
      );
    });
  }
  
  // Get all products (mock data)
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Return more products
    return List.generate(20, (index) {
      final categories = ['Fruits', 'Vegetables', 'Organic', 'Fresh Juice', 'Dairy'];
      final names = [
        'Fresh Mangoes', 'Ripe Bananas', 'Sweet Pineapples', 'Hass Avocados',
        'Juicy Tomatoes', 'Red Onions', 'Green Peppers', 'Carrots',
        'Watermelons', 'Oranges', 'Passion Fruits', 'Pawpaws',
        'Cabbage', 'Spinach', 'Eggplants', 'Potatoes',
        'Mango Juice', 'Passion Juice', 'Pineapple Juice', 'Mixed Juice'
      ];
      
      return Product(
        id: (index + 1).toString(),
        name: names[index % names.length],
        description: 'Fresh ${names[index % names.length].toLowerCase()}',
        price: 500 + (index * 300).toDouble(),
        unit: index % 2 == 0 ? 'per kg' : 'each',
        category: categories[index % categories.length],
        imageUrl: '',
        rating: 3.0 + (index % 5 * 0.5),
        stock: 5 + (index % 25),
        isOrganic: index % 4 == 0,
        isFeatured: index < 8,
      );
    });
  }
  
  // Get product by ID (mock data)
  Future<Product> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final products = await getProducts();
    return products.firstWhere(
      (product) => product.id == id,
      orElse: () => products.first,
    );
  }
  
  // Get categories (mock data)
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Category(id: '1', name: 'Fruits', productCount: 8),
      Category(id: '2', name: 'Vegetables', productCount: 12),
      Category(id: '3', name: 'Fresh Juice', productCount: 5),
      Category(id: '4', name: 'Organic', productCount: 15),
      Category(id: '5', name: 'Dairy', productCount: 7),
    ];
  }
  
  // Search products (mock data)
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final allProducts = await getProducts();
    return allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}