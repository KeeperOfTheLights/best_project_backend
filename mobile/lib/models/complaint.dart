import 'order.dart';

// Complaint model - represents a complaint filed by a consumer
class Complaint {
  final String id;
  final String orderId;
  final String? orderItemId; // Optional: specific item in the order
  final String consumerId;
  final String supplierId;
  final String title; // Complaint title
  final String accountName; // Consumer's account name
  final String issueType; // e.g., 'damaged', 'wrong_item', 'missing', 'quality', 'other'
  final String description;
  final List<String>? photoUrls; // URLs or paths to attached photos
  final String status; // 'pending', 'in_progress', 'resolved', 'escalated'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? resolutionNote; // Supplier's response/resolution
  final String? escalatedBy; // User ID who escalated (Sales -> Manager)
  
  // Optional: full objects if loaded
  final Order? order;

  Complaint({
    required this.id,
    required this.orderId,
    this.orderItemId,
    required this.consumerId,
    required this.supplierId,
    required this.title,
    required this.accountName,
    required this.issueType,
    required this.description,
    this.photoUrls,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.resolutionNote,
    this.escalatedBy,
    this.order,
  });

  // Convert JSON from backend to Complaint object
  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? json['orderId'] ?? '',
      orderItemId: json['order_item_id']?.toString() ?? json['orderItemId'],
      consumerId: json['consumer_id']?.toString() ?? json['consumerId'] ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      title: json['title'] ?? '',
      accountName: json['account_name'] ?? json['accountName'] ?? '',
      issueType: json['issue_type'] ?? json['issueType'] ?? '',
      description: json['description'] ?? '',
      photoUrls: json['photo_urls'] != null
          ? List<String>.from(json['photo_urls'])
          : json['photoUrls'] != null
              ? List<String>.from(json['photoUrls'])
              : null,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      resolutionNote: json['resolution_note'] ?? json['resolutionNote'],
      escalatedBy: json['escalated_by']?.toString() ?? json['escalatedBy']?.toString(),
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
    );
  }

  // Convert Complaint object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      if (orderItemId != null) 'order_item_id': orderItemId,
      'consumer_id': consumerId,
      'supplier_id': supplierId,
      'title': title,
      'account_name': accountName,
      'issue_type': issueType,
      'description': description,
      if (photoUrls != null) 'photo_urls': photoUrls,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (resolutionNote != null) 'resolution_note': resolutionNote,
      if (escalatedBy != null) 'escalated_by': escalatedBy,
    };
  }

  // Create a copy with updated fields
  Complaint copyWith({
    String? id,
    String? orderId,
    String? orderItemId,
    String? consumerId,
    String? supplierId,
    String? title,
    String? accountName,
    String? issueType,
    String? description,
    List<String>? photoUrls,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? resolutionNote,
    String? escalatedBy,
    Order? order,
  }) {
    return Complaint(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderItemId: orderItemId ?? this.orderItemId,
      consumerId: consumerId ?? this.consumerId,
      supplierId: supplierId ?? this.supplierId,
      title: title ?? this.title,
      accountName: accountName ?? this.accountName,
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      escalatedBy: escalatedBy ?? this.escalatedBy,
      order: order ?? this.order,
    );
  }
}

// Complaint status constants
class ComplaintStatus {
  static const String pending = 'pending';
  static const String inProgress = 'in_progress';
  static const String resolved = 'resolved';
  static const String rejected = 'rejected';  // Backend supports this
  static const String escalated = 'escalated';
}

// Issue type constants
class IssueType {
  static const String damaged = 'damaged';
  static const String wrongItem = 'wrong_item';
  static const String missing = 'missing';
  static const String quality = 'quality';
  static const String other = 'other';
  
  static List<String> getAll() {
    return [damaged, wrongItem, missing, quality, other];
  }
  
  static String getDisplayName(String type) {
    switch (type) {
      case damaged:
        return 'Damaged Item';
      case wrongItem:
        return 'Wrong Item';
      case missing:
        return 'Missing Item';
      case quality:
        return 'Quality Issue';
      case other:
        return 'Other';
      default:
        return type;
    }
  }
}

