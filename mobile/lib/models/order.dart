import 'package:flutter/foundation.dart';
import 'order_item.dart';
import 'user.dart';
import 'supplier.dart';

// Order model - represents an order
class Order {
  final String id;
  final String consumerId;
  final String supplierId;
  final String status; // 'pending', 'accepted', 'rejected', 'in_delivery', 'completed'
  final String deliveryType; // 'delivery' or 'pickup'
  final String? deliveryAddress;
  final String? comment;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  
  // Optional: full objects if loaded
  final List<OrderItem>? items;
  final User? consumer;
  final Supplier? supplier;
  final String? consumerName; // From backend consumer_name
  final String? supplierName; // From backend supplier_name

  Order({
    required this.id,
    required this.consumerId,
    required this.supplierId,
    required this.status,
    required this.deliveryType,
    this.deliveryAddress,
    this.comment,
    required this.totalAmount,
    required this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.items,
    this.consumer,
    this.supplier,
    this.consumerName,
    this.supplierName,
  });

  // Convert JSON from backend to Order object
  // Backend OrderSerializer returns: id, consumer, supplier, created_at, total_price, status, items, consumer_name, supplier_name
  // Note: consumer and supplier are IDs (integers), not full objects
  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      // Debug: Print consumer_name and supplier_name
      debugPrint('Order.fromJson: consumer_name = ${json['consumer_name']}, supplier_name = ${json['supplier_name']}');
      
      // Backend returns total_price as string (from DecimalField), need to parse
      final totalAmount = json['total_price'] != null
          ? (json['total_price'] is String ? double.parse(json['total_price']) : (json['total_price'] as num).toDouble())
          : 0.0;
      
      // Parse items safely
      List<OrderItem>? items;
      if (json['items'] != null && json['items'] is List) {
        try {
          items = (json['items'] as List)
              .map((item) {
                try {
                  return OrderItem.fromJson(item);
                } catch (e) {
                  debugPrint('Error parsing order item: $e');
                  return null;
                }
              })
              .whereType<OrderItem>()
              .toList();
        } catch (e) {
          debugPrint('Error parsing order items list: $e');
          items = null;
        }
      }
      
      return Order(
        id: json['id']?.toString() ?? '',
        consumerId: json['consumer']?.toString() ?? json['consumer_id']?.toString() ?? json['consumerId'] ?? '',
        supplierId: json['supplier']?.toString() ?? json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
        status: json['status'] ?? 'pending',
        deliveryType: json['delivery_type'] ?? json['deliveryType'] ?? 'delivery',
        deliveryAddress: json['delivery_address'] ?? json['deliveryAddress'],
        comment: json['comment'],
        totalAmount: totalAmount,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at']) // Keep UTC time like backend
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
        items: items,
        consumer: null, // Backend doesn't include full consumer object
        supplier: null, // Backend doesn't include full supplier object
        consumerName: json['consumer_name'] ?? json['consumerName'],
        supplierName: json['supplier_name'] ?? json['supplierName'],
      );
    } catch (e) {
      debugPrint('Error parsing order: $e\nOrder JSON: $json');
      rethrow;
    }
  }

  // Convert Order object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'supplier_id': supplierId,
      'status': status,
      'delivery_type': deliveryType,
      'delivery_address': deliveryAddress,
      'comment': comment,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }
}

// Order status constants
class OrderStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String inDelivery = 'in_delivery';
  static const String completed = 'completed';
}

// Delivery type constants
class DeliveryType {
  static const String delivery = 'delivery';
  static const String pickup = 'pickup';
}




