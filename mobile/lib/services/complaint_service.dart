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
  // Backend only requires: title, description
  static Future<Complaint> createComplaint({
    required String orderId,
    required String title,
    required String description,
  }) async {
    try {
      // Convert orderId to integer (backend expects integer)
      final orderIdInt = int.parse(orderId);
      
      final body = {
        'order': orderIdInt, // Backend serializer requires this field as integer
        'title': title,
        'description': description,
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
        String errorMessage = 'Failed to create complaint';
        try {
          final error = jsonDecode(response.body);
          // Handle different error formats
          if (error['detail'] != null) {
            errorMessage = error['detail'].toString();
          } else if (error['message'] != null) {
            errorMessage = error['message'].toString();
          } else if (error['title'] != null) {
            // Handle validation errors which might be lists
            final titleError = error['title'];
            errorMessage = titleError is List ? titleError.join(', ') : titleError.toString();
          } else if (error['description'] != null) {
            final descError = error['description'];
            errorMessage = descError is List ? descError.join(', ') : descError.toString();
          } else {
            errorMessage = error.toString();
          }
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}. ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // If it's already an Exception, rethrow it; otherwise wrap it
      if (e is Exception) {
        rethrow;
      }
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

