import 'package:flutter/foundation.dart';
import 'catalog_item.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String itemId;
  final String itemName;
  final String? itemDescription;
  final String unit;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  final CatalogItem? catalogItem;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    this.itemDescription,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.catalogItem,
  });



  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {

      final unitPrice = json['price'] != null
          ? (json['price'] is String ? double.parse(json['price']) : (json['price'] as num).toDouble())
          : 0.0;
      final quantity = json['quantity'] ?? 0;
      final totalPrice = unitPrice * quantity;
      
      return OrderItem(
        id: json['id']?.toString() ?? '',
        orderId: json['order']?.toString() ?? json['order_id']?.toString() ?? json['orderId'] ?? '',
        itemId: json['product']?.toString() ?? json['item_id']?.toString() ?? json['itemId'] ?? '',
        itemName: json['product_name'] ?? json['item_name'] ?? json['itemName'] ?? '',
        itemDescription: json['product_description'] ?? json['item_description'] ?? json['itemDescription'],
        unit: json['product_unit'] ?? json['unit'] ?? 'kg',
        unitPrice: unitPrice,
        quantity: quantity,
        totalPrice: totalPrice,
        catalogItem: null,
      );
    } catch (e) {
      debugPrint('Error parsing OrderItem: $e\nOrderItem JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'item_description': itemDescription,
      'unit': unit,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}




