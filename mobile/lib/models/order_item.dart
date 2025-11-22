import 'catalog_item.dart';

// OrderItem model - represents an item within an order
class OrderItem {
  final String id;
  final String orderId;
  final String itemId;
  final String itemName;
  final String? itemDescription;
  final String unit;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  
  // Optional: full catalog item if loaded
  final CatalogItem? catalogItem;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.itemName,
    this.itemDescription,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.catalogItem,
  });

  // Convert JSON from backend to OrderItem object
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? json['orderId'] ?? '',
      itemId: json['item_id']?.toString() ?? json['itemId'] ?? '',
      itemName: json['item_name'] ?? json['itemName'] ?? '',
      itemDescription: json['item_description'] ?? json['itemDescription'],
      unit: json['unit'] ?? '',
      unitPrice: (json['unit_price'] ?? json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      totalPrice: (json['total_price'] ?? json['totalPrice'] ?? 0).toDouble(),
      catalogItem: json['catalog_item'] != null || json['catalogItem'] != null
          ? CatalogItem.fromJson(json['catalog_item'] ?? json['catalogItem'])
          : null,
    );
  }

  // Convert OrderItem object to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'item_id': itemId,
      'item_name': itemName,
      'item_description': itemDescription,
      'unit': unit,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}




