import 'catalog_item.dart';

// CartItem model - represents an item in the shopping cart
class CartItem {
  final CatalogItem item;
  int quantity;

  CartItem({
    required this.item,
    required this.quantity,
  });

  // Get total price for this cart item
  double get totalPrice => item.price * quantity;

  // Check if item is available (has stock)
  bool get isAvailable => item.isActive && item.stockQuantity >= quantity;

  // Convert to JSON for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'item_id': item.id,
      'quantity': quantity,
    };
  }
}




