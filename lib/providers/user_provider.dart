// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  
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
    } else {
      _isAuthenticated = false;
      _user = null;
    }
    
    notifyListeners();
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _apiService.sessionLogin(email.trim(), password.trim());
      
      if (result['success'] == true) {
        _isAuthenticated = true;
        
        final prefs = await SharedPreferences.getInstance();
        _user = {
          'full_name': prefs.getString('user_name') ?? (result['user'] != null ? result['user']['full_name'] : ''),
          'email': prefs.getString('user_email') ?? email,
          'phone': prefs.getString('user_phone') ?? (result['user'] != null ? result['user']['phone'] : ''),
          'role': prefs.getString('user_role') ?? (result['user'] != null ? result['user']['user_type'] : 'immediate'),
        };
        
        _isLoading = false;
        notifyListeners();

        // Merge local favorites to server after login
        try {
          final prefs = await SharedPreferences.getInstance();
          final localFavs = prefs.getStringList('favorites') ?? [];
          for (final id in localFavs) {
            try {
              await _apiService.post('auth/favorites/', {'product_id': id});
            } catch (_) {}
          }
        } catch (_) {}
        return {'success': true, 'message': 'Login successful', 'user': _user};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'message': result['message'] ?? 'Login failed'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      return {'success': false, 'message': cleanMessage};
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? password2,
    String? userType,
    String? storeName,
    String? businessAddress,
    String? taxId,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        password2: password2,
        userType: userType,
        storeName: storeName,
        businessAddress: businessAddress,
        taxId: taxId,
      );
      
      _isAuthenticated = true;
      
      final prefs = await SharedPreferences.getInstance();
      _user = {
        'full_name': prefs.getString('user_name') ?? name,
        'email': prefs.getString('user_email') ?? email,
        'phone': prefs.getString('user_phone') ?? phone,
        'role': prefs.getString('user_role') ?? (userType ?? 'immediate'),
      };
      
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'message': 'Registration successful', 'user': response['user']};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      return {'success': false, 'message': cleanMessage};
    }
  }
  
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
    } catch (e) {
      print('Error during auth service logout: $e');
    }
    
    await _apiService.clearSession();
    _isAuthenticated = false;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> refreshUserData() async {
    await _loadUserData();
  }
}