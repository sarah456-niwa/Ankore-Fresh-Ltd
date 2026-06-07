// lib/services/notification_websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationWebSocketService {
  WebSocketChannel? _channel;
  final String _baseUrl;
  bool _isConnected = false;

  late StreamController<Map<String, dynamic>> _notificationController;
  late StreamController<String> _connectionStatusController;

  Stream<Map<String, dynamic>> get notifications => _notificationController.stream;
  Stream<String> get connectionStatus => _connectionStatusController.stream;

  NotificationWebSocketService({String? baseUrl}) : _baseUrl = baseUrl ?? 'ws://192.168.1.11:8000' {
    _notificationController = StreamController<Map<String, dynamic>>.broadcast();
    _connectionStatusController = StreamController<String>.broadcast();
  }

  Future<bool> connect({String? token}) async {
    if (_isConnected) return true;

    try {
      String wsUrl = '$_baseUrl/ws/notifications/user/';
      // Attach JWT token as query param if available
      if (token == null) {
        // Try reading from shared prefs
        try {
          final prefs = await SharedPreferences.getInstance();
          token = prefs.getString('access_token');
        } catch (_) {}
      }
      if (token != null && token.isNotEmpty) {
        final encoded = Uri.encodeQueryComponent(token);
        wsUrl = '$wsUrl?token=$encoded';
      }
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      await _channel!.ready;

      _isConnected = true;
      _connectionStatusController.add('connected');

      // Start listening
      _listen();

      return true;
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add('disconnected');
      return false;
    }
  }

  void _listen() {
    if (_channel == null) return;
    _channel!.stream.listen((message) {
      try {
        final data = jsonDecode(message) as Map<String, dynamic>;
        final type = data['type'] as String?;
        if (type == 'notification') {
          final payload = Map<String, dynamic>.from(data['data'] ?? {});
          _notificationController.add(payload);
        }
      } catch (e) {
        // ignore
      }
    }, onError: (err) {
      _isConnected = false;
      _connectionStatusController.add('error');
    }, onDone: () {
      _isConnected = false;
      _connectionStatusController.add('disconnected');
    });
  }

  Future<void> disconnect() async {
    try {
      if (_channel != null) {
        await _channel!.sink.close(status.goingAway);
      }
    } catch (_) {}
    _isConnected = false;
    _connectionStatusController.add('disconnected');
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _connectionStatusController.close();
  }
}
