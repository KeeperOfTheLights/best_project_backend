import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// OrderService - handles order operations
class OrderService {
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

  // Create order from cart items
  static Future<Order> createOrder({
    required String supplierId,
    required List<CartItem> items,
    required String deliveryType,
    String? deliveryAddress,
    String? comment,
  }) async {
    try {
      final body = {
        'supplier_id': supplierId,
        'items': items.map((item) => item.toJson()).toList(),
        'delivery_type': deliveryType,
        'delivery_address': deliveryAddress,
        'comment': comment,
      };

      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.createOrder}'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all orders for current user
  static Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getOrders}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ordersJson = data['orders'] ?? data;
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get orders');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get order details
  static Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getOrderDetails}/$orderId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        throw Exception('Failed to get order details');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Accept order (Supplier only)
  static Future<Order> acceptOrder(String orderId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.acceptOrder}/$orderId/accept'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to accept order');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Reject order (Supplier only)
  static Future<Order> rejectOrder(String orderId, {String? reason}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.rejectOrder}/$orderId/reject'),
        headers: _getHeaders(),
        body: jsonEncode({'rejection_reason': reason}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to reject order');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Update order status (Supplier only)
  static Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${ApiEndpoints.updateOrderStatus}/$orderId/status'),
        headers: _getHeaders(),
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}




