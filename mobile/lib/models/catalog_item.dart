// CatalogItem model - represents a product/item in the catalog
class CatalogItem {
  final String id;
  final String supplierId;
  final String name;
  final String? description;
  final String category;
  final String unit; // kg, box, piece, etc.
  final double price;
  final int stockQuantity;
  final bool isActive;
  final String? imageUrl;

  CatalogItem({
    required this.id,
    required this.supplierId,
    required this.name,
    this.description,
    required this.category,
    required this.unit,
    required this.price,
    required this.stockQuantity,
    required this.isActive,
    this.imageUrl,
  });

  // Convert JSON from backend to CatalogItem object
  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? json['supplierId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? json['stockQuantity'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      imageUrl: json['image_url'] ?? json['imageUrl'],
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
      'stock_quantity': stockQuantity,
      'is_active': isActive,
      'image_url': imageUrl,
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
    int? stockQuantity,
    bool? isActive,
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
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}




