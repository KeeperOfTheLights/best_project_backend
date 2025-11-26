import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/staff_member.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class StaffService {

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


  static Future<List<StaffMember>> getStaff() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getCompanyEmployees}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List<dynamic> staffJson = data is List ? data : (data['employees'] ?? data['staff'] ?? []);
        return staffJson.map((json) => StaffMember.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get staff');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<List<StaffMember>> getUnassignedUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getUnassignedUsers}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> usersJson = data is List ? data : (data['users'] ?? data['results'] ?? []);
        return usersJson.map((json) => StaffMember.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get unassigned users');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }



  static Future<StaffMember> addStaff({
    required String userId,
  }) async {
    try {
      final body = {
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.assignEmployee}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return StaffMember.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to add staff');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<bool> removeStaff(String userId) async {
    try {
      final body = {
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.removeEmployee}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to remove staff');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




