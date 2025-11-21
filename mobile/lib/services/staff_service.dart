import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/staff_member.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// StaffService - handles staff management operations
class StaffService {
  // Helper method to get headers with authentication token
  static Map<String, String> _getHeaders() {
    final token = StorageService.getToken();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get all staff members
  static Future<List<StaffMember>> getStaff() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getStaff}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> staffJson = data['staff'] ?? data;
        return staffJson.map((json) => StaffMember.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get staff');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Add new staff member
  static Future<StaffMember> addStaff({
    required String email,
    required String name,
    required String role,
  }) async {
    try {
      final body = {
        'email': email,
        'name': name,
        'role': role,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.addStaff}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return StaffMember.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to add staff');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Update staff member
  static Future<StaffMember> updateStaff(StaffMember staff) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.updateStaff}/${staff.id}'),
        headers: _getHeaders(),
        body: jsonEncode(staff.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StaffMember.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update staff');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Remove/deactivate staff member
  static Future<bool> removeStaff(String staffId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiEndpoints.removeStaff}/$staffId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to remove staff');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




