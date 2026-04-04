// lib/models/order.dart
class Order {
  final String id;
  final String orderNumber;
  final String status;
  final String statusDisplay;
  final String paymentStatus;
  final String paymentMethod;
  final String deliveryAddress;
  final String deliveryPhone;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double tax;
  final double total;
  final String? trackingNumber;
  final String? currentLocation;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final List<OrderItem> items;
  
  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusDisplay,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.deliveryPhone,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.tax,
    required this.total,
    this.trackingNumber,
    this.currentLocation,
    required this.createdAt,
    this.estimatedDelivery,
    this.items = const [],
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      statusDisplay: json['status_display'] ?? 'Pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cash',
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryPhone: json['delivery_phone'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      trackingNumber: json['tracking_number'],
      currentLocation: json['current_location'],
      createdAt: DateTime.parse(json['created_at']),
      estimatedDelivery: json['estimated_delivery'] != null 
          ? DateTime.parse(json['estimated_delivery']) 
          : null,
      items: json['items'] != null 
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : [],
    );
  }
  
  bool get canCancel => status == 'pending' || status == 'confirmed';
  bool get isDelivered => status == 'delivered';
  bool get isPaid => paymentStatus == 'paid';
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final double subtotal;
  
  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}