import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier.dart';
import '../models/link_request.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// LinkRequestService - handles all link request operations
class LinkRequestService {
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

  // Search suppliers by name
  static Future<List<Supplier>> searchSuppliers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.searchSuppliers}?q=$query'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> suppliersJson = data['suppliers'] ?? data;
        return suppliersJson.map((json) => Supplier.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search suppliers');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Send link request to a supplier
  static Future<LinkRequest> sendLinkRequest(String supplierId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.sendLinkRequest}'),
        headers: _getHeaders(),
        body: jsonEncode({
          'supplier_id': supplierId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return LinkRequest.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all link requests for current user (Consumer or Supplier)
  static Future<List<LinkRequest>> getLinkRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getLinkRequests}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> requestsJson = data['link_requests'] ?? data;
        return requestsJson.map((json) => LinkRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get link requests');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Approve a link request (Supplier only)
  static Future<LinkRequest> approveLinkRequest(String requestId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.approveLinkRequest}/$requestId/approve'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LinkRequest.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to approve link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Reject a link request (Supplier only)
  static Future<LinkRequest> rejectLinkRequest(String requestId, {String? reason}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.rejectLinkRequest}/$requestId/reject'),
        headers: _getHeaders(),
        body: jsonEncode({
          'rejection_reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LinkRequest.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to reject link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




