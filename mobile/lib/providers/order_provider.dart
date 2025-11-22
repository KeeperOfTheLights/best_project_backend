import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';
import '../services/mock_order_service.dart';
import '../utils/constants.dart';

// OrderProvider - manages order state
class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Get pending orders
  List<Order> get pendingOrders => getOrdersByStatus(OrderStatus.pending);

  // Get accepted orders
  List<Order> get acceptedOrders => getOrdersByStatus(OrderStatus.accepted);

  // Get in delivery orders
  List<Order> get inDeliveryOrders => getOrdersByStatus(OrderStatus.inDelivery);

  // Get completed orders
  List<Order> get completedOrders => getOrdersByStatus(OrderStatus.completed);

  // Get rejected orders
  List<Order> get rejectedOrders => getOrdersByStatus(OrderStatus.rejected);

  // Create order from cart
  Future<bool> createOrder({
    required String supplierId,
    required List<CartItem> items,
    required String deliveryType,
    String? deliveryAddress,
    String? comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = useMockApi
          ? await MockOrderService.createOrder(
              supplierId: supplierId,
              items: items,
              deliveryType: deliveryType,
              deliveryAddress: deliveryAddress,
              comment: comment,
            )
          : await OrderService.createOrder(
              supplierId: supplierId,
              items: items,
              deliveryType: deliveryType,
              deliveryAddress: deliveryAddress,
              comment: comment,
            );

      _orders.insert(0, order); // Add to beginning
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load all orders
  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final orders = useMockApi
          ? await MockOrderService.getOrders()
          : await OrderService.getOrders();

      _orders = orders;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get order details
  Future<Order?> getOrderDetails(String orderId) async {
    try {
      final order = useMockApi
          ? await MockOrderService.getOrderDetails(orderId)
          : await OrderService.getOrderDetails(orderId);

      // Update in list if exists
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = order;
        notifyListeners();
      }

      return order;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Accept order (Supplier only)
  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = useMockApi
          ? await MockOrderService.acceptOrder(orderId)
          : await OrderService.acceptOrder(orderId);

      // Update in list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = order;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reject order (Supplier only)
  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = useMockApi
          ? await MockOrderService.rejectOrder(orderId, reason: reason)
          : await OrderService.rejectOrder(orderId, reason: reason);

      // Update in list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = order;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update order status (Supplier only)
  Future<bool> updateOrderStatus(String orderId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = useMockApi
          ? await MockOrderService.updateOrderStatus(orderId, status)
          : await OrderService.updateOrderStatus(orderId, status);

      // Update in list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = order;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}




