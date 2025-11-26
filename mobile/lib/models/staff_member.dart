import '../utils/constants.dart';

class StaffMember {
  final String id;
  final String supplierId;
  final String email;
  final String name;
  final String role;
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


  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? json['company']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['full_name'] ?? json['name'] ?? '',
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

  static bool canManage(String currentUserRole, String staffRole) {
    if (currentUserRole == UserRole.owner) {

      return true;
    } else if (currentUserRole == UserRole.manager) {

      return staffRole == UserRole.sales;
    }

    return false;
  }
}

