import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';


class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> saveToken(String token) async {
    return await _prefs?.setString(StorageKeys.token, token) ?? false;
  }

  static String? getToken() {
    return _prefs?.getString(StorageKeys.token);
  }

  static Future<bool> saveRefreshToken(String refreshToken) async {
    return await _prefs?.setString(StorageKeys.refreshToken, refreshToken) ?? false;
  }

  static String? getRefreshToken() {
    return _prefs?.getString(StorageKeys.refreshToken);
  }

  static Future<bool> saveUserRole(String role) async {
    return await _prefs?.setString(StorageKeys.userRole, role) ?? false;
  }

  static String? getUserRole() {
    return _prefs?.getString(StorageKeys.userRole);
  }

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

  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  static bool isLoggedIn() {
    return getToken() != null && getToken()!.isNotEmpty;
  }

  static String? getUserId() {
    return _prefs?.getString(StorageKeys.userId);
  }

  static String? getUserEmail() {
    return _prefs?.getString(StorageKeys.userEmail);
  }

  static String? getUserName() {
    return _prefs?.getString(StorageKeys.userName);
  }

  static String? getUserBusinessName() {
    return _prefs?.getString('user_business_name');
  }

  static String? getUserCompanyName() {
    return _prefs?.getString('user_company_name');
  }

  static String? getUserAddress() {
    return _prefs?.getString('user_address');
  }

  static String? getUserPhone() {
    return _prefs?.getString('user_phone');
  }
}

