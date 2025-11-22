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
  });

  // Convert JSON from backend to Order object
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      consumerId: json['consumer_id']?.toString() ?? json['consumerId'] ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      status: json['status'] ?? 'pending',
      deliveryType: json['delivery_type'] ?? json['deliveryType'] ?? 'delivery',
      deliveryAddress: json['delivery_address'] ?? json['deliveryAddress'],
      comment: json['comment'],
      totalAmount: (json['total_amount'] ?? json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      items: json['items'] != null
          ? (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : null,
      consumer: json['consumer'] != null
          ? User.fromJson(json['consumer'])
          : null,
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'])
          : null,
    );
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




