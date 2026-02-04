// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Register new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _apiService.post('register', {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });
      
      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
      }
      
      return User.fromJson(response['user']);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  // Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('login', {
        'email': email,
        'password': password,
      });
      
      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
      }
      
      return User.fromJson(response['user']);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.post('logout', {});
      await _apiService.removeToken();
    } catch (e) {
      // Even if API fails, remove token locally
      await _apiService.removeToken();
    }
  }
  
  // Get current user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiService.get('profile');
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }
  
  // Update profile
  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('profile', data);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
  
  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post('password/forgot', {'email': email});
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }
  
  // Reset password
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    try {
      await _apiService.post('password/reset', {
        'token': token,
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}
