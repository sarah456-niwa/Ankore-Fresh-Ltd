// lib/services/auth_service.dart
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? userType,
    String? storeName,
    String? businessAddress,
  }) async {
    try {
      final response = await _apiService.post('auth/register/', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'user_type': userType ?? 'immediate',
        'store_name': storeName,
        'business_address': businessAddress,
      });
      
      if (response['access'] != null) {
        await _apiService.saveToken(response['access']);
        await _apiService.saveRefreshToken(response['refresh']);
        await _apiService.saveUserData(response['user']);
      }
      
      return response;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('auth/login/', {
        'email': email,
        'password': password,
      });
      
      if (response['access'] != null) {
        await _apiService.saveToken(response['access']);
        await _apiService.saveRefreshToken(response['refresh']);
        await _apiService.saveUserData(response['user']);
      }
      
      return response;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken != null) {
        await _apiService.post('auth/logout/', {'refresh': refreshToken});
      }
      await _apiService.removeToken();
    } catch (e) {
      await _apiService.removeToken();
    }
  }
  
  // Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiService.get('auth/profile/');
      return response;
    } catch (e) {
      throw Exception('Failed to load profile: ${e.toString()}');
    }
  }
  
  // Update profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('auth/profile/', data);
      await _apiService.saveUserData(response);
      return response;
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
  
  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post('auth/password/forgot/', {'email': email});
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }
}