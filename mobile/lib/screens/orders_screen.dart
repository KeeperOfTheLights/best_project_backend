import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'order_details_screen.dart';

// OrdersScreen - shows list of orders (Consumer or Supplier view)
class OrdersScreen extends StatelessWidget {
  final bool isConsumer;

  const OrdersScreen({super.key, this.isConsumer = true});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: isConsumer ? 5 : 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: TabBar(
            isScrollable: true,
            tabs: isConsumer
                ? const [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Accepted'),
                    Tab(text: 'In Delivery'),
                    Tab(text: 'Completed'),
                  ]
                : const [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'In Delivery'),
                    Tab(text: 'Completed'),
                  ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await orderProvider.loadOrders();
              },
              child: TabBarView(
                children: isConsumer
                    ? [
                        _buildOrderList(orderProvider.orders, orderProvider),
                        _buildOrderList(orderProvider.pendingOrders, orderProvider),
                        _buildOrderList(orderProvider.acceptedOrders, orderProvider),
                        _buildOrderList(orderProvider.inDeliveryOrders, orderProvider),
                        _buildOrderList(orderProvider.completedOrders, orderProvider),
                      ]
                    : [
                        _buildOrderList(orderProvider.orders, orderProvider),
                        _buildOrderList(orderProvider.pendingOrders, orderProvider),
                        _buildOrderList(orderProvider.inDeliveryOrders, orderProvider),
                        _buildOrderList(orderProvider.completedOrders, orderProvider),
                      ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, OrderProvider provider) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _getStatusIcon(order.status),
            title: Text(
              'Order #${order.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${_formatStatus(order.status)}'),
                Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                Text('Date: ${_formatDate(order.createdAt)}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(orderId: order.id),
                ),
              );
            },
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case OrderStatus.accepted:
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case OrderStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case OrderStatus.inDelivery:
        color = Colors.purple;
        icon = Icons.local_shipping;
        break;
      case OrderStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return CircleAvatar(
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}




