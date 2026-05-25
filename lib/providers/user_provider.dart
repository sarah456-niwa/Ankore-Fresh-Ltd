// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  
  UserProvider() {
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (isLoggedIn) {
      _isAuthenticated = true;
      _user = {
        'full_name': prefs.getString('user_name') ?? '',
        'email': prefs.getString('user_email') ?? '',
        'phone': prefs.getString('user_phone') ?? '',
        'role': prefs.getString('user_role') ?? 'immediate',
      };
    }
    
    notifyListeners();
  }
  
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', identifier.split('@')[0]);
    await prefs.setString('user_email', identifier);
    await prefs.setString('user_phone', '+2567XXXXXXXX');
    await prefs.setString('user_role', 'immediate');
    
    _isAuthenticated = true;
    _user = {
      'full_name': identifier.split('@')[0],
      'email': identifier,
      'phone': '+2567XXXXXXXX',
      'role': 'immediate',
    };
    
    _isLoading = false;
    notifyListeners();
    
    return {'success': true, 'message': 'Login successful'};
  }
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String emailCode,
    required String phoneCode,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', fullName);
    await prefs.setString('user_email', email);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_role', 'immediate');
    
    _isAuthenticated = true;
    _user = {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': 'immediate',
    };
    
    _isLoading = false;
    notifyListeners();
    
    return {'success': true, 'message': 'Registration successful'};
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
  
  Future<void> refreshUserData() async {
    await _loadUserData();
  }
}