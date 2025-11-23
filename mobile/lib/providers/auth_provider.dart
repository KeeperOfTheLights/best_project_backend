import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

// AuthProvider - manages the authentication state of the app
// This tells the app whether user is logged in or not
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Check if user is already logged in (when app starts)
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if we have a saved token
      final token = StorageService.getToken();
      final role = StorageService.getUserRole();

      if (token != null && role != null) {
        // User is logged in, we can load user data here if needed
        // For now, we just know they're authenticated
        _user = User(
          id: StorageService.getUserId() ?? '',
          email: StorageService.getUserEmail() ?? '',
          name: StorageService.getUserName() ?? '',
          role: role,
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login function
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API to login (use mock if enabled, otherwise real API)
      final authResponse = useMockApi
          ? await MockApiService.login(
              email: email,
              password: password,
            )
          : await ApiService.login(
              email: email,
              password: password,
            );

      // Save token, refresh token, and user data
      await StorageService.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }
      await StorageService.saveUserRole(authResponse.user.role);
      await StorageService.saveUserData(
        userId: authResponse.user.id,
        email: authResponse.user.email,
        name: authResponse.user.name,
        businessName: authResponse.user.businessName,
        companyName: authResponse.user.companyName,
        address: authResponse.user.address,
        phone: authResponse.user.phone,
      );

      _user = authResponse.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Signup function
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String role,
    String? businessName,
    String? companyName,
    String? companyType,
    String? address,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call API to signup (use mock if enabled, otherwise real API)
      final authResponse = useMockApi
          ? await MockApiService.signup(
              email: email,
              password: password,
              name: name,
              role: role,
              businessName: businessName,
              companyName: companyName,
              companyType: companyType,
              address: address,
              phone: phone,
            )
          : await ApiService.signup(
              email: email,
              password: password,
              name: name,
              role: role,
              businessName: businessName,
              companyName: companyName,
              companyType: companyType,
              address: address,
              phone: phone,
            );

      // Save token, refresh token, and user data
      await StorageService.saveToken(authResponse.token);
      if (authResponse.refreshToken != null) {
        await StorageService.saveRefreshToken(authResponse.refreshToken!);
      }
      await StorageService.saveUserRole(authResponse.user.role);
      await StorageService.saveUserData(
        userId: authResponse.user.id,
        email: authResponse.user.email,
        name: authResponse.user.name,
        businessName: authResponse.user.businessName,
        companyName: authResponse.user.companyName,
        address: authResponse.user.address,
        phone: authResponse.user.phone,
      );

      _user = authResponse.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout function
  Future<void> logout() async {
    await StorageService.clearAll();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

