
class CatalogItem {
  final String id;
  final String supplierId;
  final String name;
  final String? description;
  final String category;
  final String unit;
  final double price;
  final double discount;
  final double discountedPrice;
  final int stock;
  final int minOrder;
  final String status;
  final String deliveryOption;
  final int leadTimeDays;
  final String? imageUrl;
  final String? supplierName;

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

  int get stockQuantity => stock;

  bool get isActive => status == 'active';


  factory CatalogItem.fromJson(Map<String, dynamic> json) {

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


  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'category': category,
      'price': price.toStringAsFixed(2),
      'discount': discount.toStringAsFixed(2),
      'unit': unit,
      'stock': stock,
      'minOrder': minOrder,
      'status': status,
      'delivery_option': deliveryOption,
      'lead_time_days': leadTimeDays,
    };

    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      json['image'] = imageUrl;
    }

    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

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




