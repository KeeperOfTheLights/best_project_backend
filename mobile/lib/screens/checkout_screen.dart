import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart' as order_models;

// CheckoutScreen - final step to create order
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _deliveryType = order_models.DeliveryType.delivery;
  final _addressController = TextEditingController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_deliveryType == order_models.DeliveryType.delivery && _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Group items by supplier and create separate orders
    final itemsBySupplier = cartProvider.itemsBySupplier;
    
    for (final entry in itemsBySupplier.entries) {
      final supplierId = entry.key;
      final items = entry.value;

      final success = await orderProvider.createOrder(
        supplierId: supplierId,
        items: items,
        deliveryType: _deliveryType,
        deliveryAddress: _deliveryType == order_models.DeliveryType.delivery
            ? _addressController.text.trim()
            : null,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Failed to create order'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Clear cart and navigate back
    cartProvider.clearCart();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Text('Cart is empty'),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...cartProvider.itemsBySupplier.entries.map((entry) {
                            final items = entry.value;
                            final total = items.fold(
                              0.0,
                              (sum, item) => sum + item.totalPrice,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Supplier ${entry.key}:'),
                                  Text(
                                    '\$${total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                                '\$${cartProvider.totalPrice.toStringAsFixed(2)}',
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
                  const SizedBox(height: 24),

                  // Delivery type
                  const Text(
                    'Delivery Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Delivery'),
                          value: order_models.DeliveryType.delivery,
                          groupValue: _deliveryType,
                          onChanged: (value) {
                            setState(() {
                              _deliveryType = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Pickup'),
                          value: order_models.DeliveryType.pickup,
                          groupValue: _deliveryType,
                          onChanged: (value) {
                            setState(() {
                              _deliveryType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Delivery address (if delivery selected)
                  if (_deliveryType == order_models.DeliveryType.delivery)
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        hintText: 'Enter delivery address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (_deliveryType == order_models.DeliveryType.delivery &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter delivery address';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Comment
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      hintText: 'Add any special instructions...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  Consumer<OrderProvider>(
                    builder: (context, orderProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: orderProvider.isLoading ? null : _submitOrder,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: orderProvider.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Place Order'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

