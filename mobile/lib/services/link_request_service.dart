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

  // Get all suppliers (for consumer to see available suppliers)
  // Backend: GET /suppliers/ - returns all owner suppliers
  static Future<List<Supplier>> getAllSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.searchSuppliers}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly
        final List<dynamic> suppliersJson = data is List ? data : (data['suppliers'] ?? data['results'] ?? []);
        return suppliersJson.map((json) => Supplier.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get suppliers');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Search suppliers by name
  // Backend: GET /suppliers/ - returns all suppliers (no search query param, need to filter client-side or use /search/)
  static Future<List<Supplier>> searchSuppliers(String query) async {
    try {
      // Backend has /search/ endpoint - use that if query provided, otherwise use /suppliers/
      final endpoint = query.isNotEmpty 
          ? '${ApiEndpoints.globalSearch}?q=$query'  // Backend: /search/
          : ApiEndpoints.searchSuppliers;  // Backend: /suppliers/
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly or wrapped in 'suppliers'
        final List<dynamic> suppliersJson = data is List ? data : (data['suppliers'] ?? data['results'] ?? []);
        return suppliersJson.map((json) => Supplier.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to search suppliers');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Send link request to a supplier
  // Backend: POST /link/send/ with {"supplier_id": ...}
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
        // Backend returns minimal data, might need to fetch full request
        return LinkRequest.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to send link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all link requests for current user (Consumer or Supplier)
  // Backend: GET /consumer/links/ (for consumer) or GET /links/ (for supplier)
  static Future<List<LinkRequest>> getLinkRequests({required String userRole}) async {
    try {
      // Use different endpoint based on role
      final endpoint = userRole == UserRole.consumer 
          ? ApiEndpoints.getConsumerLinkRequests 
          : ApiEndpoints.getSupplierLinkRequests;
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly
        final List<dynamic> requestsJson = data is List ? data : (data['link_requests'] ?? data['results'] ?? []);
        return requestsJson.map((json) => LinkRequest.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get link requests');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Approve a link request (Supplier only)
  // Backend: PUT /link/{id}/accept/
  static Future<LinkRequest> approveLinkRequest(String requestId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.acceptLinkRequest}/$requestId/accept/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LinkRequest.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to approve link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Reject a link request (Supplier only)
  // Backend: PUT /link/{id}/reject/
  static Future<LinkRequest> rejectLinkRequest(String requestId, {String? reason}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.rejectLinkRequest}/$requestId/reject/'),
        headers: _getHeaders(),
        body: reason != null ? jsonEncode({
          'rejection_reason': reason,
        }) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LinkRequest.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to reject link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




