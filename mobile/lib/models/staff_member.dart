import '../utils/constants.dart';

// StaffMember model - represents a staff member in a supplier company
class StaffMember {
  final String id;
  final String supplierId;
  final String email;
  final String name;
  final String role; // 'owner', 'manager', 'sales'
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  StaffMember({
    required this.id,
    required this.supplierId,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert JSON from backend to StaffMember object
  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convert StaffMember object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Check if current user can manage this staff member
  static bool canManage(String currentUserRole, String staffRole) {
    if (currentUserRole == UserRole.owner) {
      // Owner can manage anyone
      return true;
    } else if (currentUserRole == UserRole.manager) {
      // Manager can only manage sales
      return staffRole == UserRole.sales;
    }
    // Sales cannot manage anyone
    return false;
  }
}

