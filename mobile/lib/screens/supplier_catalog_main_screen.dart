import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'consumer_catalog_screen.dart';
import 'catalog_management_screen.dart';
import 'sales_management_screen.dart';

// SupplierCatalogMainScreen - shows all supplier names from Sales Management for catalog viewing
class SupplierCatalogMainScreen extends StatefulWidget {
  const SupplierCatalogMainScreen({super.key});

  @override
  State<SupplierCatalogMainScreen> createState() =>
      _SupplierCatalogMainScreenState();
}

class _SupplierCatalogMainScreenState
    extends State<SupplierCatalogMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierProvider>(context, listen: false).loadMySuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? '';
    final canEdit = userRole == UserRole.owner || userRole == UserRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, child) {
          if (supplierProvider.isLoading) {
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

          final suppliers = supplierProvider.suppliers;

          if (suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No suppliers yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create supplier names in Sales Management',
                    style: TextStyle(color: Colors.grey),
                  ),
                  if (canEdit) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesManagementScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Go to Sales Management'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await supplierProvider.loadMySuppliers();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        supplier.companyName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      supplier.companyName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (supplier.companyType != null)
                          Text(supplier.companyType!),
                        Text('Supplier ID: ${supplier.id.substring(supplier.id.length - 6)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button (only for Owners/Managers)
                        if (canEdit)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CatalogManagementScreen(
                                    supplierId: supplier.id,
                                    supplierName: supplier.companyName,
                                  ),
                                ),
                              ).then((result) {
                                if (result == true && mounted) {
                                  supplierProvider.loadMySuppliers();
                                }
                              });
                            },
                            tooltip: 'Edit Products',
                            color: Colors.grey[700],
                          ),
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConsumerCatalogScreen(
                                  supplierId: supplier.id,
                                  supplierName: supplier.companyName,
                                  isSupplierView: true, // View-only mode
                                ),
                              ),
                            );
                          },
                          tooltip: 'View Products',
                          color: Colors.green,
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

