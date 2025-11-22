// User model - represents a user in our app
class User {
  final String id;
  final String email;
  final String name;
  final String role; // 'consumer' or 'supplier'
  final String? businessName; // For consumer
  final String? companyName; // For supplier
  final String? companyType; // For supplier
  final String? address;
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.businessName,
    this.companyName,
    this.companyType,
    this.address,
    this.phone,
  });

  // Convert JSON from backend to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      businessName: json['business_name'],
      companyName: json['company_name'],
      companyType: json['company_type'],
      address: json['address'],
      phone: json['phone'],
    );
  }

  // Convert User object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'business_name': businessName,
      'company_name': companyName,
      'company_type': companyType,
      'address': address,
      'phone': phone,
    };
  }
}




