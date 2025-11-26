import 'supplier.dart';
import 'user.dart';

class LinkRequest {
  final String id;
  final String consumerId;
  final String supplierId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  final String? consumerName;
  final String? supplierName;

  final Supplier? supplier;
  final User? consumer;

  LinkRequest({
    required this.id,
    required this.consumerId,
    required this.supplierId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.rejectionReason,
    this.consumerName,
    this.supplierName,
    this.supplier,
    this.consumer,
  });


  factory LinkRequest.fromJson(Map<String, dynamic> json) {
    return LinkRequest(
      id: json['id']?.toString() ?? '',
      consumerId: json['consumer']?.toString() ?? json['consumer_id']?.toString() ?? json['consumerId'] ?? '',
      supplierId: json['supplier']?.toString() ?? json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      consumerName: json['consumer_name'],
      supplierName: json['supplier_name'],
      supplier: null,
      consumer: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'supplier_id': supplierId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
    };
  }
}

class LinkRequestStatus {
  static const String pending = 'pending';
  static const String linked = 'linked';
  static const String approved = 'linked';
  static const String rejected = 'rejected';
  static const String blocked = 'blocked';
}




