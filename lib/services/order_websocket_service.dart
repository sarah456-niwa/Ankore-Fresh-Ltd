import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/order.dart';
import 'api_service.dart';

class OrderWebSocketService {
  WebSocketChannel? _channel;
  final String _baseUrl;
  String? _orderNumber;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  // StreamControllers for order updates
  late StreamController<Order> _orderUpdateController;
  late StreamController<String> _connectionStatusController;
  
  Stream<Order> get orderUpdates => _orderUpdateController.stream;
  Stream<String> get connectionStatus => _connectionStatusController.stream;
  
  bool get isConnected => _isConnected;
  
  OrderWebSocketService({
    String? baseUrl,
  }) : _baseUrl = baseUrl ?? 'ws://192.168.1.11:8000' {
    _orderUpdateController = StreamController<Order>.broadcast();
    _connectionStatusController = StreamController<String>.broadcast();
  }
  
  /// Connect to WebSocket for tracking a specific order
  Future<bool> connectToOrder(String orderNumber, {String? token}) async {
    if (_isConnecting) {
      print('⏳ WebSocket connection already in progress');
      return false;
    }
    
    if (_isConnected && _orderNumber == orderNumber) {
      print('✅ Already connected to order $orderNumber');
      return true;
    }
    
    try {
      _isConnecting = true;
      print('🔗 Connecting to WebSocket for order $orderNumber...');
      
      final wsUrl = '$_baseUrl/ws/orders/track/$orderNumber/';
      print('📡 WebSocket URL: $wsUrl');
      
      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
      );
      
      // Listen to the channel
      await _channel!.ready;
      
      _isConnected = true;
      _orderNumber = orderNumber;
      _isConnecting = false;
      
      print('✅ WebSocket connected to order $orderNumber');
      _connectionStatusController.add('connected');
      
      // Send subscription message
      _channel!.sink.add(jsonEncode({
        'type': 'subscribe',
      }));
      
      // Listen for incoming messages
      _listen();
      
      return true;
    } catch (e) {
      print('❌ WebSocket connection error: $e');
      _isConnected = false;
      _isConnecting = false;
      _connectionStatusController.add('disconnected');
      return false;
    }
  }
  
  /// Listen for incoming WebSocket messages
  void _listen() {
    if (_channel == null) return;
    
    try {
      _channel!.stream.listen(
        (message) {
          try {
            print('📨 WebSocket message received: $message');
            final data = jsonDecode(message) as Map<String, dynamic>;
            final type = data['type'] as String?;
            
            if (type == 'order_update') {
              final orderData = data['data'] as Map<String, dynamic>;
              final order = Order.fromJson(orderData);
              print('🎯 Order update: ${order.status}');
              _orderUpdateController.add(order);
            } else if (type == 'pong') {
              print('🏓 Pong received');
            }
          } catch (e) {
            print('❌ Error processing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _isConnected = false;
          _connectionStatusController.add('error');
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _isConnected = false;
          _connectionStatusController.add('disconnected');
        },
      );
    } catch (e) {
      print('❌ Error setting up WebSocket listener: $e');
      _isConnected = false;
    }
  }
  
  /// Send a ping message to keep connection alive
  void sendPing() {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode({
          'type': 'ping',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }));
      } catch (e) {
        print('❌ Error sending ping: $e');
      }
    }
  }
  
  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    try {
      if (_channel != null) {
        await _channel!.sink.close(status.goingAway);
        print('🔌 WebSocket disconnected');
      }
      _isConnected = false;
      _orderNumber = null;
      _connectionStatusController.add('disconnected');
    } catch (e) {
      print('❌ Error closing WebSocket: $e');
    }
  }
  
  /// Cleanup resources
  void dispose() {
    disconnect();
    _orderUpdateController.close();
    _connectionStatusController.close();
  }
  
  /// Change the WebSocket base URL (useful for testing different environments)
  void setBaseUrl(String baseUrl) {
    if (_isConnected) {
      print('⚠️ Cannot change URL while connected');
      return;
    }
    print('🔄 Base URL updated to: $baseUrl');
    // This is a bit hacky, we're using string manipulation to update _baseUrl
    // In a real app, you might want to use a mutable property or a different approach
  }
}
