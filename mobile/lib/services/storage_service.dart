import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

// StorageService - handles saving and retrieving data from device storage
// This is like a safe box where we store the user's login token
class StorageService {
  static SharedPreferences? _prefs;

  // Initialize storage (call this once when app starts)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save authentication token
  static Future<bool> saveToken(String token) async {
    return await _prefs?.setString(StorageKeys.token, token) ?? false;
  }

  // Get authentication token
  static String? getToken() {
    return _prefs?.getString(StorageKeys.token);
  }

  // Save refresh token
  static Future<bool> saveRefreshToken(String refreshToken) async {
    return await _prefs?.setString(StorageKeys.refreshToken, refreshToken) ?? false;
  }

  // Get refresh token
  static String? getRefreshToken() {
    return _prefs?.getString(StorageKeys.refreshToken);
  }

  // Save user role
  static Future<bool> saveUserRole(String role) async {
    return await _prefs?.setString(StorageKeys.userRole, role) ?? false;
  }

  // Get user role
  static String? getUserRole() {
    return _prefs?.getString(StorageKeys.userRole);
  }

  // Save user data
  static Future<bool> saveUserData({
    required String userId,
    required String email,
    required String name,
    String? businessName,
    String? companyName,
    String? address,
    String? phone,
  }) async {
    await _prefs?.setString(StorageKeys.userId, userId);
    await _prefs?.setString(StorageKeys.userEmail, email);
    await _prefs?.setString(StorageKeys.userName, name);
    if (businessName != null) {
      await _prefs?.setString('user_business_name', businessName);
    }
    if (companyName != null) {
      await _prefs?.setString('user_company_name', companyName);
    }
    if (address != null) {
      await _prefs?.setString('user_address', address);
    }
    if (phone != null) {
      await _prefs?.setString('user_phone', phone);
    }
    return true;
  }

  // Clear all stored data (for logout)
  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  // Check if user is logged in (has a token)
  static bool isLoggedIn() {
    return getToken() != null && getToken()!.isNotEmpty;
  }

  // Get user ID
  static String? getUserId() {
    return _prefs?.getString(StorageKeys.userId);
  }

  // Get user email
  static String? getUserEmail() {
    return _prefs?.getString(StorageKeys.userEmail);
  }

  // Get user name
  static String? getUserName() {
    return _prefs?.getString(StorageKeys.userName);
  }

  // Get user business name
  static String? getUserBusinessName() {
    return _prefs?.getString('user_business_name');
  }

  // Get user company name
  static String? getUserCompanyName() {
    return _prefs?.getString('user_company_name');
  }

  // Get user address
  static String? getUserAddress() {
    return _prefs?.getString('user_address');
  }

  // Get user phone
  static String? getUserPhone() {
    return _prefs?.getString('user_phone');
  }
}

