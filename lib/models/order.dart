// lib/models/order.dart
import 'package:flutter/material.dart';

class OrderItem {
  final int id;
  final String productName;
  final String productId;
  final double price;
  final int quantity;
  final double subtotal;
  final String? productImage;
  
  OrderItem({
    required this.id,
    required this.productName,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.productImage,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productName: json['product_name'],
      productId: json['product'].toString(),
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      subtotal: double.parse(json['subtotal'].toString()),
      productImage: json['product_image'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'product': productId,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class DeliveryAgent {
  final String? name;
  final String? phone;
  final String? vehicleNumber;
  final String? photo;
  
  DeliveryAgent({
    this.name,
    this.phone,
    this.vehicleNumber,
    this.photo,
  });
  
  factory DeliveryAgent.fromJson(Map<String, dynamic> json) {
    return DeliveryAgent(
      name: json['name'],
      phone: json['phone'],
      vehicleNumber: json['vehicle_number'],
      photo: json['photo'],
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final String statusDisplay;
  final String paymentStatus;
  final String paymentStatusDisplay;
  final String paymentMethod;
  final String paymentMethodDisplay;
  final String deliveryAddress;
  final String deliveryPhone;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double tax;
  final double total;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;
  final bool canCancel;
  final String? deliveryInstructions;
  final String? currentLocation;
  final DeliveryAgent? deliveryAgent;
  final List<Map<String, dynamic>> trackingHistory;
  
  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusDisplay,
    required this.paymentStatus,
    required this.paymentStatusDisplay,
    required this.paymentMethod,
    required this.paymentMethodDisplay,
    required this.deliveryAddress,
    required this.deliveryPhone,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.discount,
    required this.tax,
    required this.total,
    required this.items,
    required this.createdAt,
    this.estimatedDelivery,
    this.trackingNumber,
    required this.canCancel,
    this.deliveryInstructions,
    this.currentLocation,
    this.deliveryAgent,
    this.trackingHistory = const [],
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['order_number'],
      status: json['status'],
      statusDisplay: json['status_display'] ?? json['status'],
      paymentStatus: json['payment_status'],
      paymentStatusDisplay: json['payment_status_display'] ?? json['payment_status'],
      paymentMethod: json['payment_method'],
      paymentMethodDisplay: json['payment_method_display'] ?? json['payment_method'],
      deliveryAddress: json['delivery_address'],
      deliveryPhone: json['delivery_phone'],
      subtotal: double.parse(json['subtotal'].toString()),
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      serviceFee: double.parse(json['service_fee'].toString()),
      discount: double.parse(json['discount'].toString()),
      tax: double.parse(json['tax'].toString()),
      total: double.parse(json['total'].toString()),
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      estimatedDelivery: json['estimated_delivery'] != null 
          ? DateTime.parse(json['estimated_delivery']) 
          : null,
      trackingNumber: json['tracking_number'],
      canCancel: json['can_cancel'] ?? false,
      deliveryInstructions: json['delivery_instructions'],
      currentLocation: json['current_location'],
      deliveryAgent: json['delivery_agent'] != null 
          ? DeliveryAgent.fromJson(json['delivery_agent']) 
          : null,
      trackingHistory: json['tracking_history'] != null 
          ? List<Map<String, dynamic>>.from(json['tracking_history'])
          : [],
    );
  }
  
  Color getStatusColor() {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'processing': return Colors.purple;
      case 'shipped': return Colors.cyan;
      case 'out_for_delivery': return Colors.teal;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'refunded': return Colors.brown;
      default: return Colors.grey;
    }
  }
  
  IconData getStatusIcon() {
    switch (status) {
      case 'pending': return Icons.access_time;
      case 'confirmed': return Icons.check_circle_outline;
      case 'processing': return Icons.build;
      case 'shipped': return Icons.local_shipping;
      case 'out_for_delivery': return Icons.delivery_dining;
      case 'delivered': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      case 'refunded': return Icons.money_off;
      default: return Icons.shopping_bag;
    }
  }
  
  bool get isActive {
    return status != 'delivered' && status != 'cancelled' && status != 'refunded';
  }
  
  bool get isCompleted {
    return status == 'delivered' || status == 'cancelled' || status == 'refunded';
  }
  
  String getDeliveryStatusMessage() {
    switch (status) {
      case 'pending':
        return 'Your order has been placed and is awaiting confirmation.';
      case 'confirmed':
        return 'Your order has been confirmed and is being prepared.';
      case 'processing':
        return 'Your order is being prepared by the seller.';
      case 'shipped':
        if (deliveryAgent != null) {
          return 'Your order has been picked up by ${deliveryAgent!.name}. They will contact you shortly.';
        }
        return 'Your order has been shipped and is on the way.';
      case 'out_for_delivery':
        if (deliveryAgent != null) {
          return '${deliveryAgent!.name} is on the way to deliver your order. Call ${deliveryAgent!.phone} if needed.';
        }
        return 'Your order is out for delivery.';
      case 'delivered':
        return 'Your order has been delivered successfully. Thank you for shopping with us!';
      case 'cancelled':
        return 'This order has been cancelled.';
      default:
        return 'Your order is being processed.';
    }
  }
}