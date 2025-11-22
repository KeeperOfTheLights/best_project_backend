// Supplier model - represents a supplier company
class Supplier {
  final String id;
  final String companyName;
  final String? companyType;
  final String? address;
  final String? phone;
  final String? email;
  final String? description;

  Supplier({
    required this.id,
    required this.companyName,
    this.companyType,
    this.address,
    this.phone,
    this.email,
    this.description,
  });

  // Convert JSON from backend to Supplier object
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id']?.toString() ?? '',
      companyName: json['company_name'] ?? json['companyName'] ?? '',
      companyType: json['company_type'] ?? json['companyType'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
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




