// lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;
  
  // Singleton pattern - get instance
  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }
    
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    
    return _instance!;
  }
  
  // Alternative: Simple static instance (recommended)
  static Future<LocalStorageService> init() async {
    if (_instance == null) {
      _preferences = await SharedPreferences.getInstance();
      _instance = LocalStorageService();
    }
    return _instance!;
  }
  
  // Get the shared preferences instance directly
  static SharedPreferences get prefs {
    if (_preferences == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _preferences!;
  }
  
  // ========== Save Methods ==========
  
  Future<void> saveString(String key, String value) async {
    await _preferences!.setString(key, value);
  }
  
  Future<void> saveInt(String key, int value) async {
    await _preferences!.setInt(key, value);
  }
  
  Future<void> saveBool(String key, bool value) async {
    await _preferences!.setBool(key, value);
  }
  
  Future<void> saveDouble(String key, double value) async {
    await _preferences!.setDouble(key, value);
  }
  
  Future<void> saveStringList(String key, List<String> value) async {
    await _preferences!.setStringList(key, value);
  }
  
  // Save Map (convert to JSON string)
  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    await _preferences!.setString(key, jsonEncode(value));
  }
  
  // ========== Get Methods ==========
  
  String? getString(String key) {
    return _preferences!.getString(key);
  }
  
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }
  
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }
  
  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }
  
  List<String>? getStringList(String key) {
    return _preferences!.getStringList(key);
  }
  
  // Get Map (from JSON string)
  Map<String, dynamic>? getMap(String key) {
    final String? jsonString = _preferences!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }
  
  // Get value with default
  String getStringOrDefault(String key, String defaultValue) {
    return _preferences!.getString(key) ?? defaultValue;
  }
  
  int getIntOrDefault(String key, int defaultValue) {
    return _preferences!.getInt(key) ?? defaultValue;
  }
  
  bool getBoolOrDefault(String key, bool defaultValue) {
    return _preferences!.getBool(key) ?? defaultValue;
  }
  
  // ========== Remove Methods ==========
  
  Future<void> remove(String key) async {
    await _preferences!.remove(key);
  }
  
  Future<void> removeMultiple(List<String> keys) async {
    for (var key in keys) {
      await _preferences!.remove(key);
    }
  }
  
  // ========== Clear Methods ==========
  
  Future<void> clearAll() async {
    await _preferences!.clear();
  }
  
  // ========== Check Methods ==========
  
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
  
  // ========== User Session Management ==========
  
  // Save user session after login
  Future<void> saveUserSession({
    required String accessToken,
    required String refreshToken,
    required String userName,
    required String userEmail,
    required String userType,
    String? storeName,
    bool isVerifiedSeller = false,
  }) async {
    await saveString('access_token', accessToken);
    await saveString('refresh_token', refreshToken);
    await saveString('user_name', userName);
    await saveString('user_email', userEmail);
    await saveString('user_type', userType);
    await saveString('store_name', storeName ?? '');
    await saveBool('is_verified_seller', isVerifiedSeller);
    await saveBool('is_logged_in', true);
  }
  
  // Clear user session on logout
  Future<void> clearUserSession() async {
    await remove('access_token');
    await remove('refresh_token');
    await remove('user_name');
    await remove('user_email');
    await remove('user_type');
    await remove('store_name');
    await remove('is_verified_seller');
    await saveBool('is_logged_in', false);
  }
  
  // Check if user is logged in
  bool get isLoggedIn {
    return getBoolOrDefault('is_logged_in', false);
  }
  
  // Get access token
  String? get accessToken => getString('access_token');
  
  // Get user data
  String? get userName => getString('user_name');
  String? get userEmail => getString('user_email');
  String? get userType => getString('user_type');
  String? get storeName => getString('store_name');
  bool get isVerifiedSeller => getBoolOrDefault('is_verified_seller', false);
  
  // ========== Cart Session Management ==========
  
  // Save cart items count
  Future<void> saveCartCount(int count) async {
    await saveInt('cart_count', count);
  }
  
  int get cartCount => getIntOrDefault('cart_count', 0);
  
  // ========== Onboarding Management ==========
  
  Future<void> setOnboardingCompleted() async {
    await saveBool('onboarding_completed', true);
  }
  
  bool get hasCompletedOnboarding => getBoolOrDefault('onboarding_completed', false);
  
  // ========== App Settings ==========
  
  Future<void> saveThemeMode(String mode) async {
    await saveString('theme_mode', mode);
  }
  
  String get themeMode => getStringOrDefault('theme_mode', 'light');
  
  Future<void> saveNotificationSettings(bool enabled) async {
    await saveBool('notifications_enabled', enabled);
  }
  
  bool get notificationsEnabled => getBoolOrDefault('notifications_enabled', true);
}

// Add this import at the top for JSON encoding/decoding
import 'dart:convert';