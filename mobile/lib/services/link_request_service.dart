import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier.dart';
import '../models/link_request.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class LinkRequestService {

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


  static Future<List<Supplier>> getAllSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.searchSuppliers}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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


  static Future<List<Supplier>> searchSuppliers(String query) async {
    try {

      final endpoint = query.isNotEmpty 
          ? '${ApiEndpoints.globalSearch}?q=$query'
          : ApiEndpoints.searchSuppliers;
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to send link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<List<LinkRequest>> getLinkRequests({required String userRole}) async {
    try {

      final endpoint = userRole == UserRole.consumer 
          ? ApiEndpoints.getConsumerLinkRequests 
          : ApiEndpoints.getSupplierLinkRequests;
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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


  static Future<void> approveLinkRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.acceptLinkRequest}/$requestId/accept/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {


        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to approve link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<void> rejectLinkRequest(String requestId, {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.rejectLinkRequest}/$requestId/reject/'),
        headers: _getHeaders(),
        body: reason != null ? jsonEncode({
          'rejection_reason': reason,
        }) : null,
      );

      if (response.statusCode == 200) {


        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to reject link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<void> blockLinkRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.acceptLinkRequest}/$requestId/block/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {


        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to block link request');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<void> unlinkConsumer(String linkId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiEndpoints.unlink}/$linkId/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {

        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to unlink consumer');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




