import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/catalog_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadFromBackend(List<CartItemResponse> backendItems) async {
    _cartItems.clear();
    for (var item in backendItems) {
      final catalogItem = item.toCatalogItem();
      _cartItems.add(CartItem(
        id: item.id,
        item: catalogItem,
        quantity: item.quantity,
      ));
    }
    notifyListeners();
  }

  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

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

  void addItem(CatalogItem item, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == item.id,
    );

    if (existingIndex != -1) {

      final existingItem = _cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      if (newQuantity <= item.stockQuantity) {
        _cartItems[existingIndex] = CartItem(
          item: item,
          quantity: newQuantity,
        );
      } else {

        throw Exception('Not enough stock available');
      }
    } else {

      if (quantity <= item.stockQuantity) {
        _cartItems.add(CartItem(item: item, quantity: quantity));
      } else {
        throw Exception('Not enough stock available');
      }
    }
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _cartItems.indexWhere(
      (cartItem) => cartItem.item.id == itemId,
    );

    if (index != -1) {
      final cartItem = _cartItems[index];
      
      if (quantity <= 0) {

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

  void removeItem(String itemId) {
    _cartItems.removeWhere((cartItem) => cartItem.item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  List<CartItem> getItemsForSupplier(String supplierId) {
    return _cartItems.where(
      (item) => item.item.supplierId == supplierId,
    ).toList();
  }

  bool hasItemsForSupplier(String supplierId) {
    return _cartItems.any((item) => item.item.supplierId == supplierId);
  }
}




