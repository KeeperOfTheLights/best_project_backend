import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier.dart';
import '../models/catalog_item.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// SearchService - handles search operations
class SearchService {
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

  // Perform global search (suppliers, products, categories)
  // Backend: GET /search/?q=<query>
  // Returns: {suppliers: [], categories: [], products: []}
  static Future<Map<String, dynamic>> search(String query) async {
    if (query.trim().isEmpty) {
      return {
        'suppliers': <Supplier>[],
        'categories': <String>[],
        'products': <CatalogItem>[],
      };
    }

    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.globalSearch}?q=$encodedQuery'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      }

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to search');
      }

      final data = jsonDecode(response.body);
      
      // Parse suppliers
      final List<Supplier> suppliers = [];
      if (data['suppliers'] != null && data['suppliers'] is List) {
        suppliers.addAll(
          (data['suppliers'] as List)
              .map((json) => Supplier.fromJson(json))
              .whereType<Supplier>(),
        );
      }

      // Parse categories (list of strings)
      final List<String> categories = [];
      if (data['categories'] != null && data['categories'] is List) {
        categories.addAll(
          (data['categories'] as List)
              .whereType<String>()
              .toList(),
        );
      }

      // Parse products
      final List<CatalogItem> products = [];
      if (data['products'] != null && data['products'] is List) {
        products.addAll(
          (data['products'] as List)
              .map((json) {
                try {
                  return CatalogItem.fromJson(json);
                } catch (e) {
                  print('Error parsing product: $e');
                  return null;
                }
              })
              .whereType<CatalogItem>(),
        );
      }

      return {
        'suppliers': suppliers,
        'categories': categories,
        'products': products,
      };
    } catch (e) {
      throw Exception('Search error: ${e.toString()}');
    }
  }

  // Check if consumer has any linked suppliers
  // This is used to determine if search should be enabled
  // Backend: GET /consumer/links/ - returns link requests
  static Future<bool> hasLinkedSuppliers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getConsumerLinkRequests}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 401) {
        return false;
      }

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);
      final List<dynamic> links = data is List ? data : (data['links'] ?? data['results'] ?? []);
      
      // Check if there's at least one link with status "linked"
      return links.any((link) => link['status'] == 'linked');
    } catch (e) {
      return false;
    }
  }
}

