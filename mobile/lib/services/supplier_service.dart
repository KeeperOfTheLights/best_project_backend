import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// SupplierService - handles supplier management operations (Sales Management)
class SupplierService {
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

  // Get all suppliers created by current user (Owner/Manager)
  static Future<List<Supplier>> getMySuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suppliers/my-suppliers'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> suppliersJson = data['suppliers'] ?? data;
        return suppliersJson.map((json) => Supplier.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get suppliers');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Create new supplier (Sales name)
  static Future<Supplier> createSupplier({
    required String companyName,
    String? companyType,
    String? address,
    String? phone,
    String? email,
    String? description,
  }) async {
    try {
      final body = {
        'company_name': companyName,
        if (companyType != null) 'company_type': companyType,
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (description != null) 'description': description,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/suppliers'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Supplier.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create supplier');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Update supplier
  static Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/suppliers/${supplier.id}'),
        headers: _getHeaders(),
        body: jsonEncode(supplier.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Supplier.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update supplier');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Delete supplier
  static Future<bool> deleteSupplier(String supplierId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/suppliers/$supplierId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete supplier');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}

