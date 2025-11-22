import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/order_item.dart';

// MockOrderService - simulates order operations for testing
class MockOrderService {
  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Mock orders storage
  static final List<Order> _orders = [];
  static int _nextOrderId = 1;
  static int _nextOrderItemId = 1;

  // Create order from cart items
  static Future<Order> createOrder({
    required String supplierId,
    required List<CartItem> items,
    required String deliveryType,
    String? deliveryAddress,
    String? comment,
  }) async {
    await _delay();

    // Calculate total amount
    double totalAmount = 0;
    final orderItems = <OrderItem>[];

    for (final cartItem in items) {
      final itemTotal = cartItem.totalPrice;
      totalAmount += itemTotal;

      orderItems.add(OrderItem(
        id: '${_nextOrderItemId++}',
        orderId: '${_nextOrderId}',
        itemId: cartItem.item.id,
        itemName: cartItem.item.name,
        itemDescription: cartItem.item.description,
        unit: cartItem.item.unit,
        unitPrice: cartItem.item.price,
        quantity: cartItem.quantity,
        totalPrice: itemTotal,
        catalogItem: cartItem.item,
      ));
    }

    // Get current user ID from storage (mock)
    final consumerId = 'current_user_id';

    final newOrder = Order(
      id: '${_nextOrderId++}',
      consumerId: consumerId,
      supplierId: supplierId,
      status: OrderStatus.pending,
      deliveryType: deliveryType,
      deliveryAddress: deliveryAddress,
      comment: comment,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      items: orderItems,
    );

    _orders.add(newOrder);
    return newOrder;
  }

  // Get all orders for current user
  static Future<List<Order>> getOrders() async {
    await _delay();
    return List.from(_orders);
  }

  // Get order details
  static Future<Order> getOrderDetails(String orderId) async {
    await _delay();
    
    final order = _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
    
    return order;
  }

  // Accept order
  static Future<Order> acceptOrder(String orderId) async {
    await _delay();
    
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final order = _orders[index];
    final updatedOrder = Order(
      id: order.id,
      consumerId: order.consumerId,
      supplierId: order.supplierId,
      status: OrderStatus.accepted,
      deliveryType: order.deliveryType,
      deliveryAddress: order.deliveryAddress,
      comment: order.comment,
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
      items: order.items,
      consumer: order.consumer,
      supplier: order.supplier,
    );

    _orders[index] = updatedOrder;
    return updatedOrder;
  }

  // Reject order
  static Future<Order> rejectOrder(String orderId, {String? reason}) async {
    await _delay();
    
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final order = _orders[index];
    final updatedOrder = Order(
      id: order.id,
      consumerId: order.consumerId,
      supplierId: order.supplierId,
      status: OrderStatus.rejected,
      deliveryType: order.deliveryType,
      deliveryAddress: order.deliveryAddress,
      comment: order.comment,
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
      rejectionReason: reason,
      items: order.items,
      consumer: order.consumer,
      supplier: order.supplier,
    );

    _orders[index] = updatedOrder;
    return updatedOrder;
  }

  // Update order status
  static Future<Order> updateOrderStatus(String orderId, String status) async {
    await _delay();
    
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final order = _orders[index];
    final updatedOrder = Order(
      id: order.id,
      consumerId: order.consumerId,
      supplierId: order.supplierId,
      status: status,
      deliveryType: order.deliveryType,
      deliveryAddress: order.deliveryAddress,
      comment: order.comment,
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
      rejectionReason: order.rejectionReason,
      items: order.items,
      consumer: order.consumer,
      supplier: order.supplier,
    );

    _orders[index] = updatedOrder;
    return updatedOrder;
  }
}

