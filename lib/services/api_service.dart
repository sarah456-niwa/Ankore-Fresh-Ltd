// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        print('⏰ GET request timed out after 60 seconds');
        throw TimeoutException('Request timed out. Please try again.');
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch: ${response.statusCode}');
    }
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    print('🌐 POST Request to: $url');
    print('📦 Request data: $data');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        print('⏰ POST request timed out after 60 seconds');
        throw TimeoutException('Request timed out. Please try again.');
      },
    );
    
    print('📊 Response status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post: ${response.statusCode}');
    }
  }
  
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        print('⏰ PUT request timed out after 60 seconds');
        throw TimeoutException('Request timed out. Please try again.');
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  }
  
  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        print('⏰ DELETE request timed out after 60 seconds');
        throw TimeoutException('Request timed out. Please try again.');
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.statusCode == 204 ? null : jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  }
}