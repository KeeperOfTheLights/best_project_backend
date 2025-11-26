import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../utils/constants.dart';

class ApiService {

  static Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }



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


        final transformedData = {
          'token': data['access'] ?? data['token'] ?? '',
          'refresh': data['refresh'] ?? '',
          'user': {
            'id': data['id']?.toString() ?? '',
            'email': data['email'] ?? '',
            'name': data['full_name'] ?? '',
            'role': data['role'] ?? '',
          }
        };
        return AuthResponse.fromJson(transformedData);
      } else {
        final error = jsonDecode(response.body);

        String errorMessage = 'Invalid email or password';
        if (error is Map) {

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

      Map<String, dynamic> body = {
        'full_name': name,
        'email': email,
        'password': password,
        'password2': password,
        'role': role,
      };



      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.signup}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);


        final transformedData = {
          'token': data['token'] ?? '',
          'refresh': data['refresh'] ?? '',
          'user': {
            'id': data['id']?.toString() ?? '',
            'email': email,
            'name': name,
            'role': data['role'] ?? role,
          }
        };
        return AuthResponse.fromJson(transformedData);
      } else {
        final error = jsonDecode(response.body);

        String errorMessage = 'Signup failed';
        if (error is Map) {

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

