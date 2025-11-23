import 'catalog_item.dart';

// CartItem model - represents an item in the shopping cart
class CartItem {
  final String id; // Cart item ID from backend
  final CatalogItem item;
  int quantity;

  CartItem({
    required this.item,
    required this.quantity,
    this.id = '',
  });

  // Get total price for this cart item (uses discounted price)
  double get totalPrice => item.discountedPrice * quantity;

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




