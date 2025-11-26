import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';


class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {

      final token = StorageService.getToken();
      final role = StorageService.getUserRole();

      if (token != null && role != null) {


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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await ApiService.login(
        email: email,
        password: password,
      );

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
      final authResponse = await ApiService.signup(
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

  Future<void> logout() async {
    await StorageService.clearAll();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

