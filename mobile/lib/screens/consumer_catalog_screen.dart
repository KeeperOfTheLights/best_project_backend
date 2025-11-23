import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/catalog_item.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

// ConsumerCatalogScreen - matches website modal design with cart section at bottom
class ConsumerCatalogScreen extends StatefulWidget {
  final String supplierId;
  final String supplierName;

  const ConsumerCatalogScreen({
    super.key,
    required this.supplierId,
    required this.supplierName,
  });

  @override
  State<ConsumerCatalogScreen> createState() => _ConsumerCatalogScreenState();
}

class _ConsumerCatalogScreenState extends State<ConsumerCatalogScreen> {
  final Map<String, int> _quantities = {};
  String? _loadingProductId;
  String? _cartMessage;
  String? _cartError;
  bool _isLoadingCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCatalog();
      _loadCart();
    });
  }

  Future<void> _loadCatalog() async {
    final provider = Provider.of<CatalogProvider>(context, listen: false);
    await provider.loadCatalogBySupplier(widget.supplierId);
    // Initialize quantities with minOrder
    final products = provider.getFilteredItems();
    for (var product in products) {
      _quantities[product.id] = product.minOrder;
    }
    setState(() {});
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoadingCart = true;
      _cartError = null;
    });

    try {
      final cartItems = await CartService.getCart();
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.loadFromBackend(cartItems);
    } catch (e) {
      setState(() {
        _cartError = e.toString();
      });
    } finally {
      setState(() {
        _isLoadingCart = false;
      });
    }
  }

  void _updateQuantity(String productId, int delta, CatalogItem product) {
    setState(() {
      final current = _quantities[productId] ?? product.minOrder;
      final newQuantity = (current + delta).clamp(product.minOrder, product.stock);
      _quantities[productId] = newQuantity;
    });
  }

  Future<void> _addToCart(CatalogItem product) async {
    final quantity = _quantities[product.id] ?? product.minOrder;
    
    setState(() {
      _loadingProductId = product.id;
      _cartError = null;
      _cartMessage = null;
    });

    try {
      await CartService.addToCart(product.id, quantity);
      await _loadCart();
      setState(() {
        _cartMessage = 'Added $quantity ${product.unit} of ${product.name} to cart.';
      });
      // Clear message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _cartMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _cartError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loadingProductId = null;
      });
    }
  }

  Future<void> _updateCartItem(String itemId, int quantity) async {
    setState(() {
      _loadingProductId = itemId;
      _cartError = null;
      _cartMessage = null;
    });

    try {
      await CartService.updateCartItem(itemId, quantity);
      await _loadCart();
    } catch (e) {
      setState(() {
        _cartError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loadingProductId = null;
      });
    }
  }

  Future<void> _removeCartItem(String itemId) async {
    setState(() {
      _loadingProductId = itemId;
      _cartError = null;
    });

    try {
      await CartService.removeCartItem(itemId);
      await _loadCart();
    } catch (e) {
      setState(() {
        _cartError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loadingProductId = null;
      });
    }
  }

  Future<void> _proceedToCheckout() async {
    // Check if cart has items for this supplier
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final supplierCartItems = cartProvider.cartItems
        .where((item) => item.item.supplierId == widget.supplierId)
        .toList();
    
    if (supplierCartItems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cart is empty'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _cartError = null;
      _cartMessage = null;
    });

    try {
      // Call backend checkout endpoint
      final result = await CartService.checkout();
      
      if (result['success'] == true) {
        final orderId = result['orderId']?.toString() ?? '';
        
        // Show success message
        setState(() {
          _cartMessage = 'Order #$orderId placed successfully.';
        });
        
        // Reload cart (should be empty now)
        await _loadCart();
        
        // Reload orders so they appear in My Orders
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        await orderProvider.loadOrders();
        
        // Clear message after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _cartMessage = null;
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _cartError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6DEDE),
        title: Text(
          "${widget.supplierName}'s Catalog",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, catalogProvider, child) {
          final products = catalogProvider.getFilteredItems();
          
          return Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              // Get cart items for this supplier
              final supplierCartItems = cartProvider.cartItems
                  .where((item) => item.item.supplierId == widget.supplierId)
                  .toList();
              
              return Column(
                children: [
                  // Products section
                  Expanded(
                    child: catalogProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : catalogProvider.errorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    catalogProvider.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : products.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No products available in this catalog',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _loadCatalog,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(16.0),
                                      itemCount: products.length,
                                      itemBuilder: (context, index) {
                                        final product = products[index];
                                        final quantity = _quantities[product.id] ?? product.minOrder;
                                        final isInCart = supplierCartItems.any((item) => item.item.id == product.id);
                                        final cartItem = isInCart
                                            ? supplierCartItems.firstWhere((item) => item.item.id == product.id)
                                            : null;
                                        
                                        return _buildProductCard(
                                          product,
                                          quantity,
                                          isInCart,
                                          cartItem?.quantity ?? 0,
                                        );
                                      },
                                    ),
                                  ),
                  ),
                  
                  // Cart section at bottom
                  _buildCartSection(supplierCartItems, cartProvider),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    CatalogItem product,
    int quantity,
    bool isInCart,
    int cartQuantity,
  ) {
    final isLoading = _loadingProductId == product.id;
    final price = product.discountedPrice;
    
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and category
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20232A),
              ),
            ),
            if (product.description != null && product.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                product.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 12),
            
            // Product details
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bar_chart, size: 16, color: Color(0xFF61DAFB)),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${product.stock} ${product.unit}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2, size: 16, color: Colors.brown),
                    const SizedBox(width: 4),
                    Text(
                      'Min Order: ${product.minOrder} ${product.unit}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (product.deliveryOption == 'pickup' || product.deliveryOption == 'both')
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_shipping, size: 16, color: Colors.brown),
                      const SizedBox(width: 4),
                      Text(
                        product.deliveryOption == 'pickup' ? 'Pickup' : 'Pickup/Delivery',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Price
            Text(
              '${price.toStringAsFixed(0)} ₸',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF61DAFB),
              ),
            ),
            const SizedBox(height: 12),
            
            // Quantity selector and Add to Cart button
            Row(
              children: [
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > product.minOrder
                            ? () => _updateQuantity(product.id, -1, product)
                            : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        width: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: quantity < product.stock
                            ? () => _updateQuantity(product.id, 1, product)
                            : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Add to Cart button
                Expanded(
                  child: ElevatedButton(
                    onPressed: (product.stock == 0 || isLoading) ? null : () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Green
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            product.stock == 0 ? 'Out of Stock' : 'Add to Cart',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
            
            // In cart indicator
            if (isInCart && cartQuantity > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E7DD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '✓ In Cart: $cartQuantity ${product.unit}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0F5132),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection(List<dynamic> supplierCartItems, CartProvider cartProvider) {
    final total = supplierCartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.item.discountedPrice * item.quantity),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cart header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart (${supplierCartItems.length} items)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20232A),
                  ),
                ),
                if (_isLoadingCart)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          
          // Cart messages
          if (_cartError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8D7DA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _cartError!,
                style: const TextStyle(color: Color(0xFF842029)),
              ),
            ),
          if (_cartMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD1E7DD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _cartMessage!,
                style: const TextStyle(color: Color(0xFF0F5132)),
              ),
            ),
          
          // Cart items
          if (supplierCartItems.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No items from this supplier yet.',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            )
          else
            ...supplierCartItems.map((cartItem) => _buildCartItemTile(cartItem)),
          
          // Total and checkout button
          if (supplierCartItems.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(0)} ₸',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF61DAFB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _proceedToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50), // Green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCartItemTile(CartItem cartItem) {
    final isLoading = _loadingProductId == cartItem.id.toString();
    final product = cartItem.item;
    final quantity = cartItem.quantity;
    
    return ListTile(
      leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? Image.network(
              product.imageUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.inventory_2),
            )
          : const Icon(Icons.inventory_2),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${product.discountedPrice.toStringAsFixed(0)} ₸'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: isLoading
                      ? null
                      : () => _updateCartItem(cartItem.id.toString(), quantity - 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: isLoading || quantity >= product.stock
                      ? null
                      : () => _updateCartItem(cartItem.id.toString(), quantity + 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: isLoading
                ? null
                : () => _removeCartItem(cartItem.id.toString()),
          ),
        ],
      ),
    );
  }
}
