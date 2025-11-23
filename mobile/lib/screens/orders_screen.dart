import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import 'order_details_screen.dart';
import 'create_complaint_screen.dart';

// OrdersScreen - shows list of orders matching website design
// For suppliers: Order Management with Accept/Reject/Deliver actions
// For consumers: My Orders with View Details/File Complaint
class OrdersScreen extends StatefulWidget {
  final bool isConsumer;

  const OrdersScreen({super.key, this.isConsumer = true});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String? _actionLoadingId; // Track which order is being processed

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

  // Calculate order statistics for supplier view
  Map<String, dynamic> _calculateSupplierStats(List<Order> orders) {
    int pending = 0;
    int processing = 0; // approved status
    int completed = 0; // delivered status
    double totalRevenue = 0.0;

    for (var order in orders) {
      if (order.status == 'pending') {
        pending++;
      } else if (order.status == 'approved') {
        processing++;
      } else if (order.status == 'delivered') {
        completed++;
        totalRevenue += order.totalAmount;
      }
    }

    return {
      'pending': pending,
      'processing': processing,
      'completed': completed,
      'revenue': totalRevenue,
    };
  }

  // Calculate order statistics for consumer view
  Map<String, int> _calculateConsumerStats(List<Order> orders) {
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

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    )} ₸';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'approved':
        return 'PROCESSING';
      case 'delivered':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return const Color(0xFF9C27B0); // Purple
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleAcceptOrder(String orderId) async {
    setState(() {
      _actionLoadingId = orderId;
    });

    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      final success = await provider.acceptOrder(orderId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order accepted'),
              backgroundColor: Colors.green,
            ),
          );
          await provider.loadOrders();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.errorMessage ?? "Failed to accept order"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingId = null;
        });
      }
    }
  }

  Future<void> _handleRejectOrder(String orderId) async {
    setState(() {
      _actionLoadingId = orderId;
    });

    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      final success = await provider.rejectOrder(orderId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          await provider.loadOrders();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.errorMessage ?? "Failed to reject order"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingId = null;
        });
      }
    }
  }

  Future<void> _handleDeliverOrder(String orderId) async {
    setState(() {
      _actionLoadingId = orderId;
    });

    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      final success = await provider.deliverOrder(orderId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order marked as delivered'),
              backgroundColor: Colors.green,
            ),
          );
          await provider.loadOrders();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.errorMessage ?? "Failed to deliver order"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? '';
    final isCatalogManager = userRole == UserRole.owner || userRole == UserRole.manager;

    return Scaffold(
      backgroundColor: const Color(0xFFBFB7B7), // Light gray background matching website
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6DEDE), // Light pink matching website header
        title: Text(
          widget.isConsumer ? 'My Orders' : 'Order Management',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
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

          final stats = widget.isConsumer
              ? _calculateConsumerStats(orderProvider.orders)
              : _calculateSupplierStats(orderProvider.orders);

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
                      Text(
                        widget.isConsumer ? 'My Orders' : 'Order Management',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: orderProvider.isLoading
                            ? null
                            : () async {
                                await orderProvider.loadOrders();
                              },
                        icon: orderProvider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  if (widget.isConsumer) ...[
                    // Consumer stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.hourglass_empty,
                            '${stats['pending']}',
                            'Pending',
                            const Color(0xFFFFF3CD),
                            const Color(0xFF856404),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            Icons.local_shipping,
                            '${stats['inTransit']}',
                            'Approved',
                            const Color(0xFFCFE2FF),
                            const Color(0xFF084298),
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
                            const Color(0xFFD1E7DD),
                            const Color(0xFF0F5132),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            Icons.inventory_2,
                            '${stats['total']}',
                            'Total Orders',
                            const Color(0xFFE2E3E5),
                            const Color(0xFF20232A),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Supplier stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            Icons.description,
                            '${stats['pending']}',
                            'Pending Orders',
                            const Color(0xFFFFF3CD),
                            const Color(0xFF856404),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            Icons.settings,
                            '${stats['processing']}',
                            'Processing',
                            const Color(0xFFCFE2FF),
                            const Color(0xFF9C27B0),
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
                            '${stats['completed']}',
                            'Completed',
                            const Color(0xFFD1E7DD),
                            const Color(0xFF0F5132),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            Icons.attach_money,
                            _formatCurrency(stats['revenue'] as double),
                            'Total Revenue',
                            const Color(0xFFD1ECF1),
                            const Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                              Text(
                                widget.isConsumer
                                    ? "You haven't placed any orders yet."
                                    : "No orders found.",
                                style: const TextStyle(
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
                    ...orderProvider.orders.map((order) => widget.isConsumer
                        ? _buildConsumerOrderCard(order)
                        : _buildSupplierOrderCard(order, isCatalogManager)),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                      fontSize: 20,
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

  Widget _buildSupplierOrderCard(Order order, bool isCatalogManager) {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.consumerName ?? 'Unknown Consumer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20232A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF61DAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Consumer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF61DAFB)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER DATE',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(order.createdAt.toLocal()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF20232A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Items
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20232A),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Product',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF20232A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Quantity',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF20232A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Price',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF20232A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table Rows
                  ...(order.items ?? []).map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.itemName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF20232A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF20232A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatCurrency(item.unitPrice),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF61DAFB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Total Amount and Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF20232A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20232A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons - wrapped in Wrap to prevent overflow
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    // Action buttons for suppliers
                    if (!widget.isConsumer && isCatalogManager) ...[
                      if (order.status == 'pending') ...[
                        ElevatedButton.icon(
                          onPressed: _actionLoadingId == order.id
                              ? null
                              : () => _handleAcceptOrder(order.id),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(_actionLoadingId == order.id ? 'Processing...' : 'Accept Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _actionLoadingId == order.id
                              ? null
                              : () => _handleRejectOrder(order.id),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ] else if (order.status == 'approved') ...[
                        ElevatedButton.icon(
                          onPressed: _actionLoadingId == order.id
                              ? null
                              : () => _handleDeliverOrder(order.id),
                          icon: const Icon(Icons.local_shipping, size: 18),
                          label: Text(_actionLoadingId == order.id ? 'Processing...' : 'Mark as Delivered'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ] else if (order.status == 'delivered') ...[
                        ElevatedButton(
                          onPressed: null, // Generate Invoice - not implemented yet
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: const Text('Generate Invoice'),
                        ),
                      ],
                    ],
                    // View Details button (always available)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(orderId: order.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF61DAFB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsumerOrderCard(Order order) {
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
                _formatDate(order.createdAt.toLocal()),
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
}
