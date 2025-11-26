import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/catalog_item.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class CatalogService {

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


  static Future<List<CatalogItem>> getCatalogBySupplier(String supplierId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getCatalogBySupplier}/$supplierId/catalog/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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


  static Future<List<CatalogItem>> getMyCatalog() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getMyProducts}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

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

          if (error['detail'] != null) {
            errorMessage = error['detail'].toString();
          } else if (error['message'] != null) {
            errorMessage = error['message'].toString();
          } else if (error is Map) {

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


  static Future<CatalogItem> toggleProductStatus(String productId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiEndpoints.toggleProductStatus}/$productId/status/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {



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




