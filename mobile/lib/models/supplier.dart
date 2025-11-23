// Supplier model - represents a supplier company
class Supplier {
  final String id;
  final String companyName;
  final String? fullName; // Backend uses full_name
  final String? companyType;
  final String? address;
  final String? phone;
  final String? email;
  final String? description;

  Supplier({
    required this.id,
    required this.companyName,
    this.fullName,
    this.companyType,
    this.address,
    this.phone,
    this.email,
    this.description,
  });

  // Convert JSON from backend to Supplier object
  // Backend SupplierSerializer returns: id, full_name, email, role, supplier_company
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id']?.toString() ?? '',
      companyName: json['supplier_company'] ?? json['company_name'] ?? json['companyName'] ?? json['full_name'] ?? '',
      fullName: json['full_name'] ?? json['fullName'],
      companyType: json['company_type'] ?? json['companyType'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'] ?? '',
      description: json['description'],
    );
  }

  // Convert Supplier object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'company_type': companyType,
      'address': address,
      'phone': phone,
      'email': email,
      'description': description,
    };
  }
}




