
class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? businessName;
  final String? companyName;
  final String? companyType;
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


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      role: json['role'] ?? '',
      businessName: json['business_name'],
      companyName: json['company_name'],
      companyType: json['company_type'],
      address: json['address'],
      phone: json['phone'],
    );
  }

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




