import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import 'create_complaint_screen.dart';

// OrderDetailsScreen - shows detailed order information
class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false)
          .getOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isConsumer = authProvider.user?.role == UserRole.consumer;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId}'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final order = orderProvider.orders.firstWhere(
            (o) => o.id == widget.orderId,
            orElse: () => Order(
              id: widget.orderId,
              consumerId: '',
              supplierId: '',
              status: '',
              deliveryType: '',
              totalAmount: 0,
              createdAt: DateTime.now(),
            ),
          );

          if (order.id != widget.orderId) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order status card
                Card(
                  color: _getStatusColor(order.status),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(order.status), color: Colors.white),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatStatus(order.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Order ID', order.id),
                        _buildInfoRow(
                          'Date',
                          _formatDate(order.createdAt),
                        ),
                        _buildInfoRow(
                          'Delivery Type',
                          order.deliveryType == DeliveryType.delivery
                              ? 'Delivery'
                              : 'Pickup',
                        ),
                        if (order.deliveryAddress != null)
                          _buildInfoRow('Address', order.deliveryAddress!),
                        if (order.comment != null)
                          _buildInfoRow('Comment', order.comment!),
                        if (order.rejectionReason != null)
                          _buildInfoRow(
                            'Rejection Reason',
                            order.rejectionReason!,
                            isError: true,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Items
                if (order.items != null && order.items!.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...order.items!.map((item) => ListTile(
                                title: Text(item.itemName),
                                subtitle: Text('${item.quantity} ${item.unit}'),
                                trailing: Text(
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${order.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Create Complaint button (Consumer only, for completed orders)
                if (isConsumer && order.status == OrderStatus.completed) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateComplaintScreen(
                              orderId: order.id,
                            ),
                          ),
                        );
                        // Refresh if complaint was created
                        if (result == true && mounted) {
                          // Optionally refresh order details
                        }
                      },
                      icon: const Icon(Icons.report_problem),
                      label: const Text('File a Complaint'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions (Supplier only)
                if (!isConsumer && order.status == OrderStatus.pending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptOrder(context, orderProvider, order.id),
                          icon: const Icon(Icons.check),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rejectOrder(context, orderProvider, order.id),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Update status (Supplier only, for accepted orders)
                if (!isConsumer &&
                    (order.status == OrderStatus.accepted ||
                        order.status == OrderStatus.inDelivery)) ...[
                  if (order.status == OrderStatus.accepted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(
                          context,
                          orderProvider,
                          order.id,
                          OrderStatus.inDelivery,
                        ),
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Mark as In Delivery'),
                      ),
                    ),
                  if (order.status == OrderStatus.inDelivery)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(
                          context,
                          orderProvider,
                          order.id,
                          OrderStatus.completed,
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Completed'),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isError ? Colors.red : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: isError ? Colors.red : null),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.inDelivery:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.rejected:
        return Icons.cancel;
      case OrderStatus.inDelivery:
        return Icons.local_shipping;
      case OrderStatus.completed:
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _acceptOrder(
    BuildContext context,
    OrderProvider provider,
    String orderId,
  ) async {
    final success = await provider.acceptOrder(orderId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order accepted'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to accept order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectOrder(
    BuildContext context,
    OrderProvider provider,
    String orderId,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.rejectOrder(
        orderId,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to reject order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    OrderProvider provider,
    String orderId,
    String status,
  ) async {
    final success = await provider.updateOrderStatus(orderId, status);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}




