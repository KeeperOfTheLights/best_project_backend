import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';
import '../services/storage_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  List<Order> get pendingOrders => getOrdersByStatus(OrderStatus.pending);

  List<Order> get acceptedOrders => getOrdersByStatus(OrderStatus.accepted);

  List<Order> get inDeliveryOrders => getOrdersByStatus(OrderStatus.inDelivery);

  List<Order> get completedOrders => getOrdersByStatus(OrderStatus.completed);

  List<Order> get rejectedOrders => getOrdersByStatus(OrderStatus.rejected);

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
      final order = await OrderService.createOrder(
        supplierId: supplierId,
        items: items,
        deliveryType: deliveryType,
        deliveryAddress: deliveryAddress,
        comment: comment,
      );

      _orders.insert(0, order);
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

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRole = StorageService.getUserRole() ?? '';
      debugPrint('OrderProvider: Loading orders for role: $userRole');
      
      final orders = await OrderService.getOrders(userRole: userRole);

      _orders = orders;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

      debugPrint('OrderProvider: Loaded ${orders.length} orders');
      if (orders.isNotEmpty) {
        for (var order in orders.take(3)) {
          debugPrint('OrderProvider: Order #${order.id} - Status: ${order.status} - Total: ${order.totalAmount}');
        }
      } else {
        debugPrint('OrderProvider: No orders found');
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      _isLoading = false;
      _orders = [];
      notifyListeners();
      debugPrint('OrderProvider: Error loading orders: $e');
      debugPrint('OrderProvider: Stack trace: $stackTrace');
    }
  }

  Future<Order?> getOrderDetails(String orderId) async {
    try {
      final order = await OrderService.getOrderDetails(orderId);

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

  Future<bool> acceptOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await OrderService.acceptOrder(orderId);

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

  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await OrderService.rejectOrder(orderId, reason: reason);

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

  Future<bool> deliverOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await OrderService.deliverOrder(orderId);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}




