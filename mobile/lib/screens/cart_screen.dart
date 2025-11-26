import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/link_request_provider.dart';
import '../models/cart_item.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.text('Shopping Cart')),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final itemsBySupplier = cartProvider.itemsBySupplier;
          final linkProvider = Provider.of<LinkRequestProvider>(context, listen: false);
          final approvedLinks = linkProvider.getApprovedRequests();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: itemsBySupplier.length,
                  itemBuilder: (context, index) {
                    final supplierId = itemsBySupplier.keys.elementAt(index);
                    final items = itemsBySupplier[supplierId]!;
                    final supplierTotal = items.fold(
                      0.0,
                      (sum, item) => sum + item.totalPrice,
                    );

                    String supplierName = 'Supplier';
                    try {
                      final link = approvedLinks.firstWhere(
                        (l) => l.supplierId == supplierId,
                      );
                      supplierName = link.supplier?.companyName ?? supplierId;
                    } catch (e) {

                      supplierName = supplierId;
                    }

                    return Card(
                      margin: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.business, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    supplierName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${supplierTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          ...items.map((cartItem) => _buildCartItemTile(
                                context,
                                cartProvider,
                                cartItem,
                              )),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
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
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    CartProvider cartProvider,
    CartItem cartItem,
  ) {
    return ListTile(
      leading: const Icon(Icons.inventory_2),
      title: Text(cartItem.item.name),
      subtitle: Text(
        '\$${cartItem.item.price.toStringAsFixed(2)}/${cartItem.item.unit}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              if (cartItem.quantity > 1) {
                cartProvider.updateQuantity(cartItem.item.id, cartItem.quantity - 1);
              } else {
                cartProvider.removeItem(cartItem.item.id);
              }
            },
          ),
          Text(
            '${cartItem.quantity}',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              try {
                cartProvider.updateQuantity(
                  cartItem.item.id,
                  cartItem.quantity + 1,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              cartProvider.removeItem(cartItem.item.id);
            },
          ),
        ],
      ),
      isThreeLine: true,
      dense: true,
    );
  }
}




