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
  // Backend returns: {"access": "...", "refresh": "...", "id": ..., "full_name": "...", "role": "...", "email": "..."}
  // We transform it to: {"token": "...", "user": {"id": ..., "email": "...", "name": "...", "role": "..."}}
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
        // Transform backend response to match AuthResponse format
        // Backend uses "access" for token and returns user fields directly (not nested)
        final transformedData = {
          'token': data['access'] ?? data['token'] ?? '',  // Backend uses "access"
          'user': {
            'id': data['id']?.toString() ?? '',
            'email': data['email'] ?? '',
            'name': data['full_name'] ?? '',  // Backend uses "full_name"
            'role': data['role'] ?? '',
          }
        };
        return AuthResponse.fromJson(transformedData);
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['detail'] ?? error['message'] ?? error.toString();
        throw Exception('Login failed: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('Connection error')) {
        rethrow;
      }
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Signup - creates a new user account
  // Backend expects: {"email": "...", "password": "...", "password2": "...", "full_name": "...", "role": "..."}
  // Backend returns: {"token": "...", "refresh": "...", "id": ..., "role": "..."}
  // We transform it to: {"token": "...", "user": {"id": ..., "email": "...", "name": "...", "role": "..."}}
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
      // Prepare the data to send - backend expects "full_name" not "name", and "password2"
      Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'password2': password,  // Backend requires password confirmation
        'full_name': name,  // Backend expects "full_name"
        'role': role,
      };

      // Backend doesn't expect these extra fields in register (based on RegisterSerializer)
      // These might need to be added to user profile later, but not in initial registration

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.signup}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Transform backend response to match AuthResponse format
        // Backend returns token, id, role (minimal data)
        final transformedData = {
          'token': data['token'] ?? '',  // Register uses "token"
          'user': {
            'id': data['id']?.toString() ?? '',
            'email': email,  // We send this, backend might not return it
            'name': name,  // We send full_name as name
            'role': data['role'] ?? role,
          }
        };
        return AuthResponse.fromJson(transformedData);
      } else {
        final error = jsonDecode(response.body);
        // Backend might return errors in different formats
        String errorMessage = 'Signup failed';
        if (error is Map) {
          errorMessage = error['detail'] ?? 
                        error['message'] ?? 
                        (error.values.isNotEmpty ? error.values.first.toString() : 'Signup failed');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Connection error')) {
        rethrow;
      }
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}

