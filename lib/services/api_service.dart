// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // CHANGE THIS TO YOUR COMPUTER'S IP ADDRESS
  // Run 'ipconfig' in PowerShell to find your IPv4 Address
  // Example: 192.168.1.100

  static const String baseUrl = 'http://172.31.4.30:8000/api';
  
  // Alternative configurations (comment/uncomment as needed):
  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // For iOS Simulator:
  // static const String baseUrl = 'http://localhost:8000/api';
  
  // Get headers with auth token
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('📡 GET Request: $url');  // Debug print
      
      final response = await http.get(
        url,
        headers: await getHeaders(),
      );
      
      print('📡 Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('📡 POST Request: $url');
      print('📡 Body: $data');
      
      final response = await http.post(
        url,
        headers: await getHeaders(),
        body: json.encode(data),
      );
      
      print('📡 Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('📡 PUT Request: $url');
      
      final response = await http.put(
        url,
        headers: await getHeaders(),
        body: json.encode(data),
      );
      
      print('📡 Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('📡 DELETE Request: $url');
      
      final response = await http.delete(
        url,
        headers: await getHeaders(),
      );
      
      print('📡 Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network error: $e');
    }
  }
  
  // Handle response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return null;
        }
        return json.decode(response.body);
      case 400:
        final error = json.decode(response.body);
        throw Exception(error.toString());
      case 401:
        throw Exception('Unauthorized. Please login again.');
      case 403:
        throw Exception('Forbidden. You don\'t have permission.');
      case 404:
        throw Exception('Not found');
      case 500:
        throw Exception('Server error. Please try again later.');
      default:
        throw Exception('Error: ${response.statusCode}');
    }
  }
  
  // Token management
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setBool('is_logged_in', true);
    print('✅ Token saved');
  }
  
  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);
    print('✅ Refresh token saved');
  }
  
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userData['name'] ?? '');
    await prefs.setString('user_email', userData['email'] ?? '');
    await prefs.setString('user_type', userData['user_type'] ?? 'immediate');
    await prefs.setString('store_name', userData['store_name'] ?? '');
    await prefs.setBool('is_verified_seller', userData['is_verified_seller'] ?? false);
    print('✅ User data saved');
  }
  
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_type');
    await prefs.remove('store_name');
    await prefs.remove('is_verified_seller');
    await prefs.setBool('is_logged_in', false);
    print('✅ Token removed');
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}