// lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;
  
  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }
    
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    
    return _instance!;
  }
  
  // Save data
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
  
  // Get data
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
  
  // Remove data
  Future<void> remove(String key) async {
    await _preferences!.remove(key);
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await _preferences!.clear();
  }
  
  // Check if key exists
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
}