import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/catalog_item.dart';

// CartProvider - manages shopping cart state
class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  // Get total number of items in cart
  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get total price of all items in cart
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get cart items grouped by supplier
  Map<String, List<CartItem>> get itemsBySupplier {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _cartItems) {
      final supplierId = item.item.supplierId;
      if (!grouped.containsKey(supplierId)) {
        grouped[supplierId] = [];
      }
      grouped[supplierId]!.add(item);
    }
    return grouped;
  }

  // Add item to cart
  void addItem(CatalogItem item, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingIndex != -1) {
      // Item already in cart, update quantity
      final existingItem = _cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      if (newQuantity <= item.stockQuantity) {
        _cartItems[existingIndex] = CartItem(
          item: item,
          quantity: newQuantity,
        );
      } else {
        // Can't add more than stock
        throw Exception('Not enough stock available');
      }
    } else {
      // New item, add to cart
      if (quantity <= item.stockQuantity) {
        _cartItems.add(CartItem(item: item, quantity: quantity));
      } else {
        throw Exception('Not enough stock available');
      }
    }
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String itemId, int quantity) {
    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == itemId,
    );

    if (index != -1) {
      final cartItem = _cartItems[index];
      
      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        _cartItems.removeAt(index);
      } else if (quantity <= cartItem.item.stockQuantity) {
        _cartItems[index] = CartItem(
          item: cartItem.item,
          quantity: quantity,
        );
      } else {
        throw Exception('Not enough stock available');
      }
      notifyListeners();
    }
  }

  // Remove item from cart
  void removeItem(String itemId) {
    _cartItems.removeWhere((cartItem) => cartItem.item.id == itemId);
    notifyListeners();
  }

  // Clear entire cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Get items for a specific supplier
  List<CartItem> getItemsForSupplier(String supplierId) {
    return _cartItems.where(
      (item) => item.item.supplierId == supplierId,
    ).toList();
  }

  // Check if cart has items for a supplier
  bool hasItemsForSupplier(String supplierId) {
    return _cartItems.any((item) => item.item.supplierId == supplierId);
  }
}




