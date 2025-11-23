import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  // Get consumer order statistics
  // Backend: GET /api/accounts/orders/stats/
  // Returns: {"completed_orders": int, "in_progress_orders": int, "cancelled_orders": int, "total_spent": float}
  static Future<Map<String, dynamic>> getConsumerOrderStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getConsumerOrderStats}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'completed_orders': data['completed_orders'] ?? 0,
          'in_progress_orders': data['in_progress_orders'] ?? 0,
          'cancelled_orders': data['cancelled_orders'] ?? 0,
          'total_spent': (data['total_spent'] ?? 0).toDouble(),
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to fetch order stats');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get supplier order statistics
  // Backend: GET /api/accounts/orders/supplier/stats/
  // Returns: {"active_orders": int, "completed_orders": int, "pending_deliveries": int, "total_revenue": float}
  static Future<Map<String, dynamic>> getSupplierOrderStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getSupplierOrderStats}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns total_revenue as DecimalField (string or number)
        final totalRevenue = data['total_revenue'] != null
            ? (data['total_revenue'] is String 
                ? double.parse(data['total_revenue']) 
                : (data['total_revenue'] as num).toDouble())
            : 0.0;
        
        return {
          'active_orders': data['active_orders'] ?? 0,
          'completed_orders': data['completed_orders'] ?? 0,
          'pending_deliveries': data['pending_deliveries'] ?? 0,
          'total_revenue': totalRevenue,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to fetch supplier order stats');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Create order from cart items (checkout)
  // Backend: POST /orders/checkout/ - uses cart items, doesn't take items in body
  // Note: Backend automatically creates order from cart items, so we just call checkout
  static Future<Order> createOrder({
    required String supplierId,
    required List<CartItem> items,
    required String deliveryType,
    String? deliveryAddress,
    String? comment,
  }) async {
    try {
      // Backend checkout endpoint uses cart items from database, not from request body
      // So we just call checkout without sending items
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.checkout}'),
        headers: _getHeaders(),
        // Backend doesn't expect any body for checkout - it uses cart items from DB
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get all orders for current user
  // Backend: GET /orders/my/ (consumer) or GET /orders/supplier/ (supplier)
  static Future<List<Order>> getOrders({required String userRole}) async {
    try {
      final endpoint = userRole == UserRole.consumer 
          ? ApiEndpoints.getMyOrders 
          : ApiEndpoints.getSupplierOrders;
      final url = '$baseUrl$endpoint';
      
      debugPrint('OrderService: Fetching orders from: $url');
      debugPrint('OrderService: User role: $userRole');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      debugPrint('OrderService: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('OrderService: Response data type: ${data.runtimeType}');
        
        // Backend returns array directly
        final List<dynamic> ordersJson = data is List ? data : (data['orders'] ?? data['results'] ?? []);
        debugPrint('OrderService: Found ${ordersJson.length} orders in response');
        
        // Parse orders, catching any parsing errors
        final List<Order> orders = [];
        for (var json in ordersJson) {
          try {
            final order = Order.fromJson(json);
            orders.add(order);
            debugPrint('OrderService: Successfully parsed order #${order.id}');
          } catch (e, stackTrace) {
            // Log parsing error but continue with other orders
            debugPrint('OrderService: Error parsing order: $e');
            debugPrint('OrderService: Stack trace: $stackTrace');
            debugPrint('OrderService: Order JSON: $json');
          }
        }
        
        debugPrint('OrderService: Successfully parsed ${orders.length} orders');
        return orders;
      } else {
        final error = jsonDecode(response.body);
        debugPrint('OrderService: Error response: $error');
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get orders');
      }
    } catch (e, stackTrace) {
      debugPrint('OrderService: Exception caught: $e');
      debugPrint('OrderService: Stack trace: $stackTrace');
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Get order details
  // Backend: GET /orders/{id}/
  static Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getOrderDetails}/$orderId/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get order details');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Accept order (Supplier only)
  // Backend: POST /orders/{id}/accept/
  static Future<Order> acceptOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.acceptOrder}/$orderId/accept/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to accept order');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Reject order (Supplier only)
  // Backend: POST /orders/{id}/reject/
  static Future<Order> rejectOrder(String orderId, {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.rejectOrder}/$orderId/reject/'),
        headers: _getHeaders(),
        body: reason != null ? jsonEncode({'rejection_reason': reason}) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to reject order');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Deliver order (Supplier only) - update status to delivered
  // Backend: POST /orders/{id}/deliver/
  static Future<Order> deliverOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.deliverOrder}/$orderId/deliver/'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Order.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to deliver order');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  // Note: Backend doesn't have a generic updateOrderStatus endpoint
  // Use deliverOrder() instead for changing status to delivered
}




