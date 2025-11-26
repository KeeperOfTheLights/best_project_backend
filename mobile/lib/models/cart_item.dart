import 'catalog_item.dart';

class CartItem {
  final String id;
  final CatalogItem item;
  int quantity;

  CartItem({
    required this.item,
    required this.quantity,
    this.id = '',
  });

  double get totalPrice => item.discountedPrice * quantity;

  bool get isAvailable => item.isActive && item.stockQuantity >= quantity;

  Map<String, dynamic> toJson() {
    return {
      'item_id': item.id,
      'quantity': quantity,
    };
  }
}




