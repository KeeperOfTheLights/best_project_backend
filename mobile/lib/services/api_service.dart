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
        // Backend returns: {"access": "...", "refresh": "...", "id": ..., "full_name": "...", "role": "...", "email": "..."}
        final transformedData = {
          'token': data['access'] ?? data['token'] ?? '',  // Backend uses "access"
          'refresh': data['refresh'] ?? '',  // Backend returns refresh token
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
        // Backend may return errors in different formats - match website behavior
        String errorMessage = 'Invalid email or password';
        if (error is Map) {
          // Check for non_field_errors first (matching website)
          if (error.containsKey('non_field_errors')) {
            errorMessage = error['non_field_errors'] is List
                ? error['non_field_errors'].first.toString()
                : error['non_field_errors'].toString();
          } else if (error.containsKey('detail')) {
            errorMessage = error['detail'].toString();
          } else if (error.containsKey('message')) {
            errorMessage = error['message'].toString();
          }
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

  // Signup - creates a new user account
  // Backend expects: {"full_name": "...", "email": "...", "password": "...", "password2": "...", "role": "..."}
  // Backend returns: {"message": "...", "id": ..., "role": "...", "token": "...", "refresh": "..."}
  // We transform it to: {"token": "...", "user": {"id": ..., "email": "...", "name": "...", "role": "..."}}
  static Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name, // This will be sent as 'full_name' to backend
    required String role, // consumer, owner, manager, or sales
    String? businessName, // Not used in registration
    String? companyName, // Not used in registration
    String? companyType, // Not used in registration
    String? address, // Not used in registration
    String? phone, // Not used in registration
  }) async {
    try {
      // Prepare the data to send - ONLY what backend expects (matching RegisterSerializer)
      Map<String, dynamic> body = {
        'full_name': name,  // Backend expects "full_name"
        'email': email,
        'password': password,
        'password2': password,  // Backend requires password confirmation
        'role': role,  // consumer, owner, manager, or sales
      };

      // Note: Backend RegisterSerializer only accepts: full_name, email, password, password2, role
      // Extra fields (businessName, companyName, etc.) are NOT sent during registration

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.signup}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Backend returns: {message, id, role, token, refresh}
        // Transform to AuthResponse format: {token, user: {id, email, name, role}}
        final transformedData = {
          'token': data['token'] ?? '',  // Access token
          'refresh': data['refresh'] ?? '',  // Refresh token (we'll save this separately)
          'user': {
            'id': data['id']?.toString() ?? '',
            'email': email,  // Backend doesn't return email, use what we sent
            'name': name,  // Backend doesn't return full_name, use what we sent
            'role': data['role'] ?? role,
          }
        };
        return AuthResponse.fromJson(transformedData);
      } else {
        final error = jsonDecode(response.body);
        // Backend might return errors in different formats
        String errorMessage = 'Signup failed';
        if (error is Map) {
          // Check for field-specific errors (e.g., password validation)
          if (error.containsKey('password')) {
            errorMessage = error['password'] is List 
                ? error['password'].first.toString()
                : error['password'].toString();
          } else if (error.containsKey('non_field_errors')) {
            errorMessage = error['non_field_errors'] is List
                ? error['non_field_errors'].first.toString()
                : error['non_field_errors'].toString();
          } else {
            errorMessage = error['detail'] ?? 
                          error['message'] ?? 
                          (error.values.isNotEmpty ? error.values.first.toString() : 'Signup failed');
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Connection error') || e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}

