import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../models/supplier.dart';
import 'catalog_management_screen.dart';

// SalesManagementScreen - allows Owners/Managers to create supplier names (Sales Management)
class SalesManagementScreen extends StatefulWidget {
  const SalesManagementScreen({super.key});

  @override
  State<SalesManagementScreen> createState() => _SalesManagementScreenState();
}

class _SalesManagementScreenState extends State<SalesManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierProvider>(context, listen: false).loadMySuppliers();
    });
  }

  void _showCreateSupplierDialog() {
    final companyNameController = TextEditingController();
    final companyTypeController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Supplier Name'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name *',
                  hintText: 'e.g., Fresh Food Co.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: companyTypeController,
                decoration: const InputDecoration(
                  labelText: 'Company Type',
                  hintText: 'e.g., Food Distributor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
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
              if (companyNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a company name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final supplierProvider =
                  Provider.of<SupplierProvider>(context, listen: false);
              final success = await supplierProvider.createSupplier(
                companyName: companyNameController.text.trim(),
                companyType: companyTypeController.text.trim().isEmpty
                    ? null
                    : companyTypeController.text.trim(),
                address: addressController.text.trim().isEmpty
                    ? null
                    : addressController.text.trim(),
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
                email: emailController.text.trim().isEmpty
                    ? null
                    : emailController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
              );

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Supplier created successfully! Consumers can now find it through search.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        supplierProvider.errorMessage ?? 'Failed to create supplier',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSupplierDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text(
          'Are you sure you want to delete ${supplier.companyName}? '
          'This will remove it from search and consumers will no longer be able to find it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final supplierProvider =
                  Provider.of<SupplierProvider>(context, listen: false);
              final success = await supplierProvider.deleteSupplier(supplier.id);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Supplier deleted successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        supplierProvider.errorMessage ?? 'Failed to delete supplier',
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
        title: const Text('Sales Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: _showCreateSupplierDialog,
            tooltip: 'Create Supplier',
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, child) {
          if (supplierProvider.isLoading && supplierProvider.suppliers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (supplierProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(supplierProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      supplierProvider.loadMySuppliers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (supplierProvider.suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No suppliers created yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a supplier name so consumers can find it through search',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateSupplierDialog,
                    icon: const Icon(Icons.add_business),
                    label: const Text('Create Supplier'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await supplierProvider.loadMySuppliers();
            },
            child: ListView.builder(
              itemCount: supplierProvider.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = supplierProvider.suppliers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(
                      supplier.companyName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (supplier.companyType != null)
                          Text('Type: ${supplier.companyType}'),
                        if (supplier.description != null)
                          Text(supplier.description!),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.inventory_2, color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CatalogManagementScreen(
                                  supplierId: supplier.id,
                                  supplierName: supplier.companyName,
                                ),
                              ),
                            );
                          },
                          tooltip: 'Manage Products',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteSupplierDialog(supplier),
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


