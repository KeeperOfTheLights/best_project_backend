import 'supplier.dart';
import 'user.dart';

// LinkRequest model - represents a connection request between consumer and supplier
class LinkRequest {
  final String id;
  final String consumerId;
  final String supplierId;
  final String status; // 'pending', 'linked', 'rejected', 'blocked'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  final String? consumerName; // From backend serializer
  final String? supplierName; // From backend serializer
  
  // Optional: full objects if loaded
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

  // Convert JSON from backend to LinkRequest object
  // Backend LinkRequestSerializer returns: id, supplier, consumer, status, created_at, consumer_name, supplier_name
  factory LinkRequest.fromJson(Map<String, dynamic> json) {
    return LinkRequest(
      id: json['id']?.toString() ?? '',
      consumerId: json['consumer']?.toString() ?? json['consumer_id']?.toString() ?? json['consumerId'] ?? '',
      supplierId: json['supplier']?.toString() ?? json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      status: json['status'] ?? 'pending', // Can be: pending, linked, rejected, blocked
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      consumerName: json['consumer_name'],
      supplierName: json['supplier_name'],
      supplier: null, // Supplier data not included in LinkRequestSerializer
      consumer: null, // Consumer data not included in LinkRequestSerializer
    );
  }

  // Convert LinkRequest object to JSON for sending to backend
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

// Link request status constants
class LinkRequestStatus {
  static const String pending = 'pending';
  static const String linked = 'linked'; // Backend uses 'linked' instead of 'approved'
  static const String approved = 'linked'; // Alias for compatibility
  static const String rejected = 'rejected';
  static const String blocked = 'blocked';
}




