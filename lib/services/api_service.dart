// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _baseUrl = '';
  static bool _isInitialized = false;
  
  // List of possible IPs to try (you can add more)
  static const List<String> possibleIps = [
    '10.76.28.33',
    '192.168.1.127',
    '172.31.247.99',
    '172.31.0.112',
    '192.168.1.11',
  ];
  
  static const int apiPort = 8000;
  static const String apiPath = 'api';
  
  // Cookie jar to maintain session
  static Map<String, String> _cookies = {};
  
  // Get base URL - Simplified for Chrome/Windows testing
  static Future<String> get baseUrl async {
    // Prefer in-memory override, then persisted setting, then localhost
    if (_baseUrl.isNotEmpty) return _baseUrl;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('backend_url');
      if (saved != null && saved.isNotEmpty) {
        _baseUrl = saved;
        return _baseUrl;
      }
    } catch (e) {
      // ignore and fall back
    }
    // Default for local dev
    _baseUrl = 'http://localhost:8000/api';
    return _baseUrl;
  }
  
  static Future<bool> _testConnection(String url) async {
    try {
      print('Testing connection to: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection failed to $url: $e');
      return false;
    }
  }

  // Public wrapper for testing connection from other files
  static Future<bool> testConnection(String url) async {
    return await _testConnection(url);
  }
  
  static Future<String?> _getComputerName() async {
    // For Windows
    try {
      final result = await Process.run('hostname', []);
      if (result.exitCode == 0) {
        String hostname = result.stdout.toString().trim();
        return hostname;
      }
    } catch (e) {
      print('Could not get computer name: $e');
    }
    return null;
  }
  
  // Manual URL setter (for settings screen)
  static Future<void> setBaseUrl(String newUrl) async {
    _baseUrl = newUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_url', newUrl);
    print('✅ Manually set backend URL: $newUrl');
  }
  
  // Get current base URL (use this in your API calls)
  static Future<String> getCurrentBaseUrl() async {
    return await baseUrl;
  }
  
  // Extract cookies from response
  void _extractCookies(http.Response response) {
    final cookieHeader = response.headers['set-cookie'];
    if (cookieHeader != null) {
      // Parse the cookie (simplified - just store the sessionid)
      final sessionMatch = RegExp(r'sessionid=([^;]+)').firstMatch(cookieHeader);
      if (sessionMatch != null) {
        _cookies['sessionid'] = sessionMatch.group(1)!;
        print('🍪 Session cookie extracted');
      }
    }
  }
  
  // Get headers with auth token and cookies
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add token if available
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    // Add cookies if available
    if (_cookies.isNotEmpty) {
      final cookieString = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      headers['Cookie'] = cookieString;
    }
    
    return headers;
  }
  
  // GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final base = await baseUrl;
      final url = Uri.parse('$base/$endpoint');
      print('📡 GET Request: $url');
      
      final response = await http.get(
        url,
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      // Extract cookies for session persistence
      _extractCookies(response);
      
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
      final base = await baseUrl;
      final url = Uri.parse('$base/$endpoint');
      print('📡 POST Request: $url');
      print('📡 Body: $data');
      
      final response = await http.post(
        url,
        headers: await getHeaders(),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));
      
      // Extract cookies for session persistence
      _extractCookies(response);
      
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
      final base = await baseUrl;
      final url = Uri.parse('$base/$endpoint');
      print('📡 PUT Request: $url');
      
      final response = await http.put(
        url,
        headers: await getHeaders(),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 10));
      
      // Extract cookies for session persistence
      _extractCookies(response);
      
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
      final base = await baseUrl;
      final url = Uri.parse('$base/$endpoint');
      print('📡 DELETE Request: $url');
      
      final response = await http.delete(
        url,
        headers: await getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      // Extract cookies for session persistence
      _extractCookies(response);
      
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
        try {
          return json.decode(response.body);
        } catch (e) {
          final snippet = response.body.length > 500 ? response.body.substring(0, 500) : response.body;
          // If the server returned HTML (for example an error page), include helpful context
          throw Exception('Expected JSON but received status ${response.statusCode} with body:\n${snippet}');
        }
      case 400:
        try {
          final error = json.decode(response.body);
          throw Exception(_parseApiError(error));
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Bad request: ${response.body}');
        }
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
  
  // Clear session (logout)
  Future<void> clearSession() async {
    _cookies.clear();
    await removeToken();
    print('🍪 Session cleared');
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
  
  // Optional: Add a method to refresh the backend discovery
  static Future<void> refreshBackendDiscovery() async {
    _baseUrl = '';
    _isInitialized = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_url');
    print('🔄 Backend discovery reset');
  }
  
  // Login method using session authentication
  Future<Map<String, dynamic>> sessionLogin(String email, String password) async {
    try {
      final base = await baseUrl;
      final url = Uri.parse('$base/auth/mobile-login/');
      print('📡 Login Request: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      
      // Extract session cookie
      _extractCookies(response);
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Save user data
        await saveUserData({
          'name': data['user']['full_name'],
          'email': data['user']['email'],
          'user_type': 'immediate',
        });
        
        // Save JWT tokens if provided
        if (data['access'] != null) {
          await saveToken(data['access']);
        }
        if (data['refresh'] != null) {
          await saveRefreshToken(data['refresh']);
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        
        print('✅ Session login successful');
        return {'success': true, 'message': 'Login successful', 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  String _parseApiError(dynamic error) {
    try {
      if (error is Map) {
        List<String> messages = [];
        error.forEach((key, value) {
          final cleanKey = key.toString().replaceAll('_', ' ');
          final capitalizedKey = cleanKey.isNotEmpty 
              ? cleanKey[0].toUpperCase() + cleanKey.substring(1)
              : '';
          if (value is List) {
            messages.add('$capitalizedKey: ${value.join(", ")}');
          } else {
            messages.add('$capitalizedKey: $value');
          }
        });
        return messages.join('\n');
      } else if (error is List) {
        return error.join('\n');
      }
    } catch (_) {}
    return error.toString();
  }
}