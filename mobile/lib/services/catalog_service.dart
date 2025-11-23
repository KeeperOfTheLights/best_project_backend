import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/catalog_item.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// CatalogService - handles catalog operations
class CatalogService {
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

  // Get catalog items for a specific supplier (Consumer view)
  // Backend: GET /supplier/{id}/catalog/
  static Future<List<CatalogItem>> getCatalogBySupplier(String supplierId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getCatalogBySupplier}/$supplierId/catalog/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly or wrapped in 'items' or 'products'
        final List<dynamic> itemsJson = data is List 
            ? data 
            : (data['items'] ?? data['products'] ?? data['results'] ?? []);
        return itemsJson.map((json) => CatalogItem.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get catalog');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all catalog items for current supplier (Supplier view)
  // Backend: GET /products/
  static Future<List<CatalogItem>> getMyCatalog() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getMyProducts}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns array directly
        final List<dynamic> itemsJson = data is List 
            ? data 
            : (data['items'] ?? data['products'] ?? data['results'] ?? []);
        return itemsJson.map((json) => CatalogItem.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get catalog');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Create new catalog item (Supplier only)
  // Backend: POST /products/
  static Future<CatalogItem> createItem(CatalogItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.createProduct}'),
        headers: _getHeaders(),
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CatalogItem.fromJson(data);
      } else {
        String errorMessage = 'Failed to create product';
        try {
          final error = jsonDecode(response.body);
          // Handle different error formats
          if (error['detail'] != null) {
            errorMessage = error['detail'].toString();
          } else if (error['message'] != null) {
            errorMessage = error['message'].toString();
          } else if (error is Map) {
            // Handle validation errors
            final errors = <String>[];
            error.forEach((key, value) {
              if (value is List) {
                errors.add('$key: ${value.join(", ")}');
              } else {
                errors.add('$key: $value');
              }
            });
            if (errors.isNotEmpty) {
              errorMessage = errors.join('; ');
            }
          }
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Update catalog item (Supplier only)
  // Backend: PUT /products/{id}/
  static Future<CatalogItem> updateItem(CatalogItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.updateProduct}/${item.id}/'),
        headers: _getHeaders(),
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CatalogItem.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to update item');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Delete catalog item (Supplier only)
  // Backend: DELETE /products/{id}/
  static Future<bool> deleteItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiEndpoints.deleteProduct}/$itemId/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to delete item');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Toggle product status (Supplier only)
  // Backend: PATCH /products/{id}/status/
  static Future<CatalogItem> toggleProductStatus(String productId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiEndpoints.toggleProductStatus}/$productId/status/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Backend returns {"message": "Status changed to active/inactive"}
        // We need to reload the product to get updated data
        // Try to get the product again to return updated CatalogItem
        final productResponse = await http.get(
          Uri.parse('$baseUrl${ApiEndpoints.updateProduct}/$productId/'),
          headers: _getHeaders(),
        );
        if (productResponse.statusCode == 200) {
          final productData = jsonDecode(productResponse.body);
          return CatalogItem.fromJson(productData);
        }
        throw Exception('Failed to get updated product');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? error['error'] ?? 'Failed to toggle status');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




