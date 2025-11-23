// CatalogItem model - represents a product/item in the catalog
class CatalogItem {
  final String id;
  final String supplierId;
  final String name;
  final String? description;
  final String category;
  final String unit; // kg, pcs, litre, pack
  final double price;
  final double discount; // Discount percentage (0-100)
  final double discountedPrice; // Calculated discounted price
  final int stock; // Backend uses 'stock' not 'stockQuantity'
  final int minOrder; // Minimum order quantity
  final String status; // 'active' or 'inactive'
  final String deliveryOption; // 'delivery', 'pickup', or 'both'
  final int leadTimeDays; // Lead time in days
  final String? imageUrl;
  final String? supplierName; // Supplier name from backend (for search results)

  CatalogItem({
    required this.id,
    required this.supplierId,
    required this.name,
    this.description,
    required this.category,
    required this.unit,
    required this.price,
    this.discount = 0.0,
    required this.discountedPrice,
    required this.stock,
    required this.minOrder,
    required this.status,
    required this.deliveryOption,
    this.leadTimeDays = 0,
    this.imageUrl,
    this.supplierName,
  });

  // Get stock quantity (for compatibility)
  int get stockQuantity => stock;

  // Get isActive (for compatibility)
  bool get isActive => status == 'active';

  // Convert JSON from backend to CatalogItem object
  // Backend ProductSerializer returns: id, name, category, price, discount, discounted_price, unit, stock, minOrder, image, description, status, delivery_option, lead_time_days, supplier_name
  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    // Backend returns prices as strings (from DecimalField), need to parse
    final price = json['price'] != null 
        ? (json['price'] is String ? double.parse(json['price']) : (json['price'] as num).toDouble())
        : 0.0;
    final discount = json['discount'] != null
        ? (json['discount'] is String ? double.parse(json['discount']) : (json['discount'] as num).toDouble())
        : 0.0;
    final discountedPrice = json['discounted_price'] != null
        ? (json['discounted_price'] is String ? double.parse(json['discounted_price']) : (json['discounted_price'] as num).toDouble())
        : price;

    return CatalogItem(
      id: json['id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'Uncategorized',
      unit: json['unit'] ?? 'kg',
      price: price,
      discount: discount,
      discountedPrice: discountedPrice,
      stock: json['stock'] ?? 0,
      minOrder: json['minOrder'] ?? json['min_order'] ?? 1,
      status: json['status'] ?? 'active',
      deliveryOption: json['delivery_option'] ?? json['deliveryOption'] ?? 'both',
      leadTimeDays: json['lead_time_days'] ?? json['leadTimeDays'] ?? 0,
      imageUrl: json['image'],
      supplierName: json['supplier_name'] ?? json['supplierName'],
    );
  }

  // Convert CatalogItem object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'name': name,
      'description': description,
      'category': category,
      'unit': unit,
      'price': price,
      'discount': discount,
      'stock': stock,
      'minOrder': minOrder,
      'status': status,
      'delivery_option': deliveryOption,
      'lead_time_days': leadTimeDays,
      'image': imageUrl,
    };
  }

  // Create a copy with updated fields
  CatalogItem copyWith({
    String? id,
    String? supplierId,
    String? name,
    String? description,
    String? category,
    String? unit,
    double? price,
    double? discount,
    double? discountedPrice,
    int? stock,
    int? minOrder,
    String? status,
    String? deliveryOption,
    int? leadTimeDays,
    String? imageUrl,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      stock: stock ?? this.stock,
      minOrder: minOrder ?? this.minOrder,
      status: status ?? this.status,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}




