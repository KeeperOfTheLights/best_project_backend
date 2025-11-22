import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catalog_provider.dart';
import '../models/catalog_item.dart';

// CatalogManagementScreen - allows Owners/Managers to manage products for suppliers
class CatalogManagementScreen extends StatefulWidget {
  final String supplierId;
  final String supplierName;

  const CatalogManagementScreen({
    super.key,
    required this.supplierId,
    required this.supplierName,
  });

  @override
  State<CatalogManagementScreen> createState() => _CatalogManagementScreenState();
}

class _CatalogManagementScreenState extends State<CatalogManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load catalog for this specific supplier
      final catalogProvider = Provider.of<CatalogProvider>(context, listen: false);
      // For now, load by supplier ID - in a real app, this would filter by supplierId
      catalogProvider.loadMyCatalog();
    });
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final unitController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Full Description *',
                  hintText: 'Describe the product in detail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  hintText: 'e.g., Vegetables, Meat, Dairy',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit *',
                  hintText: 'e.g., kg, box, piece',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty ||
                  categoryController.text.trim().isEmpty ||
                  unitController.text.trim().isEmpty ||
                  priceController.text.trim().isEmpty ||
                  quantityController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final price = double.tryParse(priceController.text.trim());
              final quantity = int.tryParse(quantityController.text.trim());

              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid price'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (quantity == null || quantity < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final catalogProvider =
                  Provider.of<CatalogProvider>(context, listen: false);
              
              final newItem = CatalogItem(
                id: '', // Will be set by service
                supplierId: widget.supplierId,
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                category: categoryController.text.trim(),
                unit: unitController.text.trim(),
                price: price,
                stockQuantity: quantity,
                isActive: true,
              );

              final success = await catalogProvider.createItem(newItem);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        catalogProvider.errorMessage ?? 'Failed to add product',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(CatalogItem item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description ?? '');
    final categoryController = TextEditingController(text: item.category);
    final unitController = TextEditingController(text: item.unit);
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(text: item.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Full Description *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty ||
                  categoryController.text.trim().isEmpty ||
                  unitController.text.trim().isEmpty ||
                  priceController.text.trim().isEmpty ||
                  quantityController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final price = double.tryParse(priceController.text.trim());
              final quantity = int.tryParse(quantityController.text.trim());

              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid price'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (quantity == null || quantity < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final catalogProvider =
                  Provider.of<CatalogProvider>(context, listen: false);
              
              final updatedItem = item.copyWith(
                name: nameController.text.trim(),
                description: descriptionController.text.trim(),
                category: categoryController.text.trim(),
                unit: unitController.text.trim(),
                price: price,
                stockQuantity: quantity,
              );

              final success = await catalogProvider.updateItem(updatedItem);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        catalogProvider.errorMessage ?? 'Failed to update product',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(CatalogItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final catalogProvider =
                  Provider.of<CatalogProvider>(context, listen: false);
              final success = await catalogProvider.deleteItem(item.id);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        catalogProvider.errorMessage ?? 'Failed to delete product',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products - ${widget.supplierName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, catalogProvider, child) {
          if (catalogProvider.isLoading && catalogProvider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catalogProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(catalogProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      catalogProvider.loadMyCatalog();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter items by supplier ID (in a real app, this would be done by backend)
          final supplierItems = catalogProvider.items.where(
            (item) => item.supplierId == widget.supplierId,
          ).toList();

          if (supplierItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No products yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add products to this supplier so consumers can order them',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await catalogProvider.loadMyCatalog();
            },
            child: ListView.builder(
              itemCount: supplierItems.length,
              itemBuilder: (context, index) {
                final item = supplierItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.shopping_bag, color: Colors.white),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.description != null)
                          Text(item.description!),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${item.category} | Unit: ${item.unit}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Price: \$${item.price.toStringAsFixed(2)} | Stock: ${item.stockQuantity}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.grey[700]),
                          onPressed: () => _showEditProductDialog(item),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteProductDialog(item),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

