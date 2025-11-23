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
  // Backend: POST /complaints/{order_id}/create/ - order_id in URL, not body
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
        'title': title,
        'description': description,
        // Backend expects: title, description (optional fields not in serializer)
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.createComplaint}/$orderId/create/'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Complaint.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to create complaint');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all complaints for current user (Consumer or Supplier)
  // Backend: GET /complaints/my/ (consumer) or GET /complaints/supplier/ (supplier)
  static Future<List<Complaint>> getComplaints({required String userRole}) async {
    try {
      final endpoint = userRole == UserRole.consumer 
          ? ApiEndpoints.getMyComplaints 
          : ApiEndpoints.getSupplierComplaints;
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly
        final List<dynamic> complaintsJson = data is List 
            ? data 
            : (data['complaints'] ?? data['results'] ?? []);
        return complaintsJson.map((json) => Complaint.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get complaints');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Resolve complaint (Supplier)
  // Backend: POST /complaints/{id}/resolve/
  static Future<Complaint> resolveComplaint(String complaintId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.resolveComplaint}/$complaintId/resolve/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Backend returns {"detail": "Complaint resolved"}
        // Return a simple complaint object - caller should refresh complaints list
        return Complaint.fromJson({'id': complaintId, 'status': 'resolved'});
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to resolve complaint');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Reject complaint (Supplier)
  // Backend: POST /complaints/{id}/reject/
  static Future<Complaint> rejectComplaint(String complaintId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.rejectComplaint}/$complaintId/reject/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Backend returns {"detail": "Complaint rejected"}
        return Complaint.fromJson({'id': complaintId, 'status': 'rejected'});
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to reject complaint');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Escalate complaint (Supplier Sales -> Manager)
  // Backend: POST /complaints/{id}/escalate/
  static Future<Complaint> escalateComplaint(String complaintId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.escalateComplaint}/$complaintId/escalate/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Backend returns {"detail": "Complaint escalated"}
        return Complaint.fromJson({'id': complaintId, 'status': 'escalated'});
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to escalate complaint');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}

