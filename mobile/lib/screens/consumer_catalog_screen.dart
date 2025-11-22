import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../models/catalog_item.dart';

// ConsumerCatalogScreen - allows consumers to browse supplier catalog
// Also used by suppliers for view-only mode
class ConsumerCatalogScreen extends StatefulWidget {
  final String supplierId;
  final String supplierName;
  final bool isSupplierView; // If true, view-only mode (no add to cart)

  const ConsumerCatalogScreen({
    super.key,
    required this.supplierId,
    required this.supplierName,
    this.isSupplierView = false,
  });

  @override
  State<ConsumerCatalogScreen> createState() => _ConsumerCatalogScreenState();
}

class _ConsumerCatalogScreenState extends State<ConsumerCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(context, listen: false)
          .loadCatalogBySupplier(widget.supplierId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(CatalogItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => _QuantityDialog(
        item: item,
        onConfirm: (quantity) {
          try {
            cartProvider.addItem(item, quantity: quantity);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added $quantity ${item.unit} to cart'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplierName),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Category filter
          Consumer<CatalogProvider>(
            builder: (context, provider, child) {
              if (provider.categories.isEmpty) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip(provider, null, 'All'),
                    ...provider.categories.map(
                      (category) => _buildCategoryChip(provider, category, category),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Items list
          Expanded(
            child: Consumer<CatalogProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.errorMessage!),
                      ],
                    ),
                  );
                }

                final filteredItems = provider.getFilteredItems(
                  searchQuery: _searchController.text,
                );

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadCatalogBySupplier(widget.supplierId);
                  },
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (item.description != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item.description!,
                                            style: const TextStyle(fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Price and button section
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Text(
                                        '/${item.unit}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (!widget.isSupplierView) ...[
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: 32,
                                        child: ElevatedButton.icon(
                                          onPressed: item.isActive && item.stockQuantity > 0
                                              ? () => _addToCart(item)
                                              : null,
                                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                                          label: const Text('Add', style: TextStyle(fontSize: 12)),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Category and stock row
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      item.category,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Stock: ${item.stockQuantity} ${item.unit}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(CatalogProvider provider, String? category, String label) {
    final isSelected = provider.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          provider.setCategoryFilter(selected ? category : null);
        },
      ),
    );
  }
}

// Quantity selection dialog
class _QuantityDialog extends StatefulWidget {
  final CatalogItem item;
  final Function(int) onConfirm;

  const _QuantityDialog({
    required this.item,
    required this.onConfirm,
  });

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Price: \$${widget.item.price.toStringAsFixed(2)}/${widget.item.unit}'),
          Text('Available: ${widget.item.stockQuantity} ${widget.item.unit}'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Text(
                '$_quantity',
                style: const TextStyle(fontSize: 24),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _quantity < widget.item.stockQuantity
                    ? () => setState(() => _quantity++)
                    : null,
              ),
            ],
          ),
          Text('Total: \$${(_quantity * widget.item.price).toStringAsFixed(2)}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_quantity);
            Navigator.pop(context);
          },
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}

