// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../models/order.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _selectedPaymentMethod = 'cash';
  bool _isLoading = false;
  final OrderService _orderService = OrderService();

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'label': 'Cash on Delivery', 'icon': Icons.money},
    {'value': 'momo', 'label': 'MTN Mobile Money', 'icon': Icons.phone_android},
    {'value': 'airtel', 'label': 'Airtel Money', 'icon': Icons.phone_android},
    {'value': 'card', 'label': 'Credit/Debit Card', 'icon': Icons.credit_card},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // DEBUG: Print cart items
    print('🛒 Cart has ${cartProvider.items.length} items');
    for (var item in cartProvider.items) {
      print('   - ${item.product.name} (ID: ${item.product.id}) x${item.quantity}');
    }
    
    // Check if cart is empty
    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty. Please add items first.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    // Get user info from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? 'Customer';
    final userEmail = prefs.getString('user_email') ?? '';
    final userPhone = prefs.getString('user_phone') ?? '';
    
    // Calculate fees
    final deliveryFee = 5000.0;
    final serviceFee = cartProvider.totalAmount * 0.02;
    final tax = cartProvider.totalAmount * 0.05;
    final grandTotal = cartProvider.totalAmount + deliveryFee + serviceFee + tax;
    
    // Prepare order items
    final List<Map<String, dynamic>> items = [];
    for (var cartItem in cartProvider.items) {
      items.add({
        'product_id': cartItem.product.id,
        'product': cartItem.product.id,
        'product_name': cartItem.product.name,
        'quantity': cartItem.quantity,
        'price': cartItem.product.price,
        'subtotal': cartItem.totalPrice,
      });
    }
    
    print('📦 Items being sent: $items');
    
    // Prepare order data for backend
    final orderData = {
      'customer_name': userName,
      'customer_email': userEmail,
      'customer_phone': userPhone,
      'delivery_address': _addressController.text,
      'delivery_phone': _phoneController.text,
      'delivery_instructions': _instructionsController.text,
      'payment_method': _selectedPaymentMethod,
      'subtotal': cartProvider.totalAmount,
      'delivery_fee': deliveryFee,
      'service_fee': serviceFee,
      'tax': tax,
      'total': grandTotal,
      'notes': _instructionsController.text,
      'items': items,
    };
    
    print('📦 Full order data: $orderData');
    
    // Send order to backend
    final result = await _orderService.placeOrder(orderData);
    
    setState(() {
      _isLoading = false;
    });
    
    if (result['success']) {
      // Clear cart
      cartProvider.clearCart();
      
      // Create a local order object for tracking (no API call needed)
      final localOrder = Order(
        id: result['order_id'] ?? 0,
        orderNumber: result['order_number'] ?? 'ANK-${DateTime.now().millisecondsSinceEpoch}',
        status: 'pending',
        statusDisplay: 'Pending',
        paymentStatus: 'pending',
        paymentStatusDisplay: 'Pending',
        paymentMethod: _selectedPaymentMethod,
        paymentMethodDisplay: _selectedPaymentMethod == 'cash' ? 'Cash on Delivery' : 'Mobile Money',
        deliveryAddress: _addressController.text,
        deliveryPhone: _phoneController.text,
        subtotal: cartProvider.totalAmount,
        deliveryFee: deliveryFee,
        serviceFee: serviceFee,
        discount: 0,
        tax: tax,
        total: grandTotal,
        items: cartProvider.items.map((cartItem) => OrderItem(
          id: 0,
          productName: cartItem.product.name,
          productId: cartItem.product.id,
          price: cartItem.product.price,
          quantity: cartItem.quantity,
          subtotal: cartItem.totalPrice,
          productImage: null,
        )).toList(),
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
        trackingNumber: null,
        canCancel: true,
        deliveryInstructions: _instructionsController.text,
        currentLocation: null,
        deliveryAgent: null,
        trackingHistory: [],
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              order: localOrder,  // Pass the order object directly
            ),
          ),
        );
      }
    } else {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    if (cartProvider.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Add items to proceed to checkout'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    final deliveryFee = 5000.0;
    final serviceFee = cartProvider.totalAmount * 0.02;
    final tax = cartProvider.totalAmount * 0.05;
    final grandTotal = cartProvider.totalAmount + deliveryFee + serviceFee + tax;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...cartProvider.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.product.name} x${item.quantity}')),
                          Text('UGX ${item.totalPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    )),
                    const Divider(),
                    _buildPriceRow('Subtotal', cartProvider.totalAmount),
                    _buildPriceRow('Delivery Fee', deliveryFee),
                    _buildPriceRow('Service Fee (2%)', serviceFee),
                    _buildPriceRow('Tax (5%)', tax),
                    const Divider(),
                    _buildPriceRow('Total', grandTotal, isTotal: true),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Delivery Information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Delivery Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(),
                        hintText: 'Enter your full delivery address',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter delivery address' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 07XXXXXXXX or +256XXXXXXXXX',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Instructions (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'E.g., Gate code, landmark, etc.',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Payment Method
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._paymentMethods.map((method) => RadioListTile<String>(
                      value: method['value'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                      title: Text(method['label']),
                      secondary: Icon(method['icon'], color: Colors.green),
                      activeColor: Colors.green,
                      contentPadding: EdgeInsets.zero,
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Place Order Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Place Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('UGX ${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.green : null)),
        ],
      ),
    );
  }
}