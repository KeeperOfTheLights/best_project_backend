import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import 'order_details_screen.dart';
import 'create_complaint_screen.dart';

// OrdersScreen - shows list of orders matching website design
class OrdersScreen extends StatefulWidget {
  final bool isConsumer;

  const OrdersScreen({super.key, this.isConsumer = true});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    await Provider.of<OrderProvider>(context, listen: false).loadOrders();
  }

  // Calculate order statistics matching website logic
  Map<String, int> _calculateStats(List<Order> orders) {
    int pending = 0;
    int inTransit = 0;
    int delivered = 0;
    int total = orders.length;

    for (var order in orders) {
      if (order.status == 'pending') {
        pending++;
      } else if (order.status == 'approved' || order.status == 'in-transit') {
        inTransit++;
      } else if (order.status == 'delivered') {
        delivered++;
      }
    }

    return {
      'pending': pending,
      'inTransit': inTransit,
      'delivered': delivered,
      'total': total,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background matching website
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6DEDE), // Light pink matching website header
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final stats = _calculateStats(orderProvider.orders);

          // Show error message if any
          if (orderProvider.errorMessage != null && !orderProvider.isLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${orderProvider.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => orderProvider.loadOrders(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await orderProvider.loadOrders();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Refresh button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Orders',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: orderProvider.isLoading
                            ? null
                            : () async {
                                await orderProvider.loadOrders();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827), // Dark gray matching website
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: orderProvider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Refresh',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards - matching website
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.hourglass_empty,
                          '${stats['pending']}',
                          'Pending',
                          const Color(0xFFFFF3CD), // Yellow background
                          const Color(0xFF856404), // Yellow text
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.local_shipping,
                          '${stats['inTransit']}',
                          'Approved',
                          const Color(0xFFCFE2FF), // Blue background
                          const Color(0xFF084298), // Blue text
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.check_circle,
                          '${stats['delivered']}',
                          'Delivered',
                          const Color(0xFFD1E7DD), // Green background
                          const Color(0xFF0F5132), // Green text
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          Icons.inventory_2,
                          '${stats['total']}',
                          'Total Orders',
                          const Color(0xFFE2E3E5), // Gray background
                          const Color(0xFF20232A), // Black text
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Orders List
                  if (orderProvider.orders.isEmpty)
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "You haven't placed any orders yet.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...orderProvider.orders.map((order) => _buildOrderCard(order)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color iconBg, Color iconColor) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20232A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20232A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),

              // Supplier
              _buildDetailItem(
                'Supplier:',
                order.supplierName ?? 'Supplier #${order.supplierId}',
              ),
              const SizedBox(height: 8),
              
              // Order Date
              _buildDetailItem(
                'Order Date:',
                _formatDate(order.createdAt),
              ),
              const SizedBox(height: 12),
              
              // Order Items
              const Text(
                'Order Items:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20232A),
                ),
              ),
              const SizedBox(height: 8),
              if (order.items != null && order.items!.isNotEmpty)
                ...order.items!.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF20232A),
                              ),
                            ),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF20232A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${item.unitPrice.toStringAsFixed(0)} ₸',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF20232A),
                            ),
                          ),
                        ],
                      ),
                    ))
              else
                const Text(
                  'No items',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 12),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20232A),
                    ),
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} ₸',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20232A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Action Buttons (matching website)
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateComplaintScreen(orderId: order.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'File Complaint',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (order.status == 'pending')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: null, // Disabled
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Awaiting approval',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(orderId: order.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF61DAFB), // Light blue
                        foregroundColor: const Color(0xFF20232A), // Black text
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        label = 'Pending';
        break;
      case 'approved':
      case 'in-transit':
        bgColor = const Color(0xFFCFE2FF);
        textColor = const Color(0xFF084298);
        label = 'Approved';
        break;
      case 'delivered':
        bgColor = const Color(0xFFD1E7DD);
        textColor = const Color(0xFF0F5132);
        label = 'Delivered';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF842029);
        label = 'Cancelled';
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF20232A),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
