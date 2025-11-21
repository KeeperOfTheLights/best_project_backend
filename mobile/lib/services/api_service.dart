import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../utils/constants.dart';

// ApiService - handles all communication with the backend server
class ApiService {
  // Helper method to get headers with authentication token
  static Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Login - sends email and password to backend, gets token back
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.login}'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Signup - creates a new user account
  static Future<AuthResponse> signup({
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
    try {
      // Prepare the data to send
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      };

      // Add role-specific fields
      if (role == UserRole.consumer) {
        if (businessName != null) body['business_name'] = businessName;
        if (address != null) body['address'] = address;
        if (phone != null) body['phone'] = phone;
      } else if (role == UserRole.supplier) {
        if (companyName != null) body['company_name'] = companyName;
        if (companyType != null) body['company_type'] = companyType;
        if (address != null) body['address'] = address;
        if (phone != null) body['phone'] = phone;
      }

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.signup}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}

