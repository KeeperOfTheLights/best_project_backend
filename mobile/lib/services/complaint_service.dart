import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/complaint.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// ComplaintService - handles complaint operations
class ComplaintService {
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

  // Create a new complaint (Consumer)
  static Future<Complaint> createComplaint({
    required String orderId,
    required String title,
    required String accountName,
    String? orderItemId,
    required String issueType,
    required String description,
    List<String>? photoUrls,
  }) async {
    try {
      final body = {
        'order_id': orderId,
        'title': title,
        'account_name': accountName,
        if (orderItemId != null) 'order_item_id': orderItemId,
        'issue_type': issueType,
        'description': description,
        if (photoUrls != null) 'photo_urls': photoUrls,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/complaints'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Complaint.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create complaint');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all complaints for current user (Consumer or Supplier)
  static Future<List<Complaint>> getComplaints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/complaints'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> complaintsJson = data['complaints'] ?? data;
        return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get complaints');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get complaint details
  static Future<Complaint> getComplaintDetails(String complaintId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/complaints/$complaintId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Complaint.fromJson(data);
      } else {
        throw Exception('Failed to get complaint details');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Update complaint status (Supplier: mark in progress, resolve, escalate)
  static Future<Complaint> updateComplaintStatus({
    required String complaintId,
    required String status,
    String? resolutionNote,
  }) async {
    try {
      final body = {
        'status': status,
        if (resolutionNote != null) 'resolution_note': resolutionNote,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/complaints/$complaintId/status'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Complaint.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update complaint status');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}

