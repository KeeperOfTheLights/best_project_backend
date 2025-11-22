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
  static Future<List<CatalogItem>> getCatalogBySupplier(String supplierId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getCatalogBySupplier}/$supplierId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data['items'] ?? data;
        return itemsJson.map((json) => CatalogItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get catalog');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all catalog items for current supplier (Supplier view)
  static Future<List<CatalogItem>> getMyCatalog() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getCatalog}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data['items'] ?? data;
        return itemsJson.map((json) => CatalogItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get catalog');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Create new catalog item (Supplier only)
  static Future<CatalogItem> createItem(CatalogItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.createCatalogItem}'),
        headers: _getHeaders(),
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CatalogItem.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create item');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Update catalog item (Supplier only)
  static Future<CatalogItem> updateItem(CatalogItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.updateCatalogItem}/${item.id}'),
        headers: _getHeaders(),
        body: jsonEncode(item.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CatalogItem.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update item');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Delete catalog item (Supplier only)
  static Future<bool> deleteItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiEndpoints.deleteCatalogItem}/$itemId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete item');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




