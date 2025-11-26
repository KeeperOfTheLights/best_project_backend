import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../services/storage_service.dart';
import '../models/catalog_item.dart';

class CartService {

  static String get baseUrl => getApiBaseUrl();

  static Map<String, String> _getHeaders() {
    final token = StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  static Future<List<CartItemResponse>> getCart() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.getCart}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data is List ? data : [];
        return itemsJson.map((json) => CartItemResponse.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to get cart');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<CartItemResponse> addToCart(String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.addToCart}'),
        headers: _getHeaders(),
        body: jsonEncode({
          'product_id': int.parse(productId),
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartItemResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to add to cart');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<CartItemResponse> updateCartItem(String itemId, int quantity) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${ApiEndpoints.updateCartItem}/$itemId/'),
        headers: _getHeaders(),
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CartItemResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to update cart item');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }


  static Future<void> removeCartItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${ApiEndpoints.updateCartItem}/$itemId/'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to remove cart item');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }



  static Future<Map<String, dynamic>> checkout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${ApiEndpoints.checkout}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'orderId': data['id']?.toString() ?? '',
          'order': data,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? error['message'] ?? 'Failed to checkout');
      }
    } catch (e) {
      throw Exception('Connection error: ${e.toString()}');
    }
  }
}

class CartItemResponse {
  final String id;
  final String productId;
  final String productName;
  final double productPrice;
  final double productDiscountedPrice;
  final double productDiscount;
  final String productUnit;
  final int productMinOrder;
  final int productStock;
  final String productSupplierId;
  final String? productImage;
  final int quantity;
  final double lineTotal;

  CartItemResponse({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productDiscountedPrice,
    required this.productDiscount,
    required this.productUnit,
    required this.productMinOrder,
    required this.productStock,
    required this.productSupplierId,
    this.productImage,
    required this.quantity,
    required this.lineTotal,
  });


  factory CartItemResponse.fromJson(Map<String, dynamic> json) {

    final productPrice = json['product_price'] != null
        ? (json['product_price'] is String ? double.parse(json['product_price']) : (json['product_price'] as num).toDouble())
        : 0.0;
    final productDiscountedPrice = json['product_discounted_price'] != null
        ? (json['product_discounted_price'] is String ? double.parse(json['product_discounted_price']) : (json['product_discounted_price'] as num).toDouble())
        : productPrice;
    final productDiscount = json['product_discount'] != null
        ? (json['product_discount'] is String ? double.parse(json['product_discount']) : (json['product_discount'] as num).toDouble())
        : 0.0;
    final lineTotal = json['line_total'] != null
        ? (json['line_total'] is String ? double.parse(json['line_total']) : (json['line_total'] as num).toDouble())
        : 0.0;
    
    return CartItemResponse(
      id: json['id']?.toString() ?? '',
      productId: json['product']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      productPrice: productPrice,
      productDiscountedPrice: productDiscountedPrice,
      productDiscount: productDiscount,
      productUnit: json['product_unit'] ?? 'kg',
      productMinOrder: json['product_min_order'] ?? 1,
      productStock: json['product_stock'] ?? 0,
      productSupplierId: json['product_supplier_id']?.toString() ?? '',
      productImage: json['product_image'],
      quantity: json['quantity'] ?? 1,
      lineTotal: lineTotal,
    );
  }

  CatalogItem toCatalogItem() {
    return CatalogItem(
      id: productId,
      supplierId: productSupplierId,
      name: productName,
      category: 'Uncategorized',
      unit: productUnit,
      price: productPrice,
      discount: productDiscount,
      discountedPrice: productDiscountedPrice,
      stock: productStock,
      minOrder: productMinOrder,
      status: 'active',
      deliveryOption: 'both',
      imageUrl: productImage,
    );
  }
}

