import 'supplier.dart';
import 'user.dart';

// LinkRequest model - represents a connection request between consumer and supplier
class LinkRequest {
  final String id;
  final String consumerId;
  final String supplierId;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? rejectionReason;
  
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
    this.supplier,
    this.consumer,
  });

  // Convert JSON from backend to LinkRequest object
  factory LinkRequest.fromJson(Map<String, dynamic> json) {
    return LinkRequest(
      id: json['id']?.toString() ?? '',
      consumerId: json['consumer_id']?.toString() ?? json['consumerId'] ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'])
          : null,
      consumer: json['consumer'] != null
          ? User.fromJson(json['consumer'])
          : null,
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
  static const String approved = 'approved';
  static const String rejected = 'rejected';
}




