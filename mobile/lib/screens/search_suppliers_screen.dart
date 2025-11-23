import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../models/supplier.dart';
import '../models/catalog_item.dart';
import '../services/link_request_service.dart';
import 'consumer_catalog_screen.dart';

// SearchScreen - matches website design, searches products and suppliers from linked suppliers only
class SearchSuppliersScreen extends StatefulWidget {
  const SearchSuppliersScreen({super.key});

  @override
  State<SearchSuppliersScreen> createState() => _SearchSuppliersScreenState();
}

class _SearchSuppliersScreenState extends State<SearchSuppliersScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Check for linked suppliers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).checkLinkedSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_formKey.currentState!.validate()) {
      final query = _searchController.text.trim();
      Provider.of<SearchProvider>(context, listen: false).search(query);
    }
  }

  void _handleSupplierClick(Supplier supplier) {
    final supplierName = supplier.fullName ?? supplier.companyName;
    if (supplierName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier name not available')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsumerCatalogScreen(
          supplierId: supplier.id,
          supplierName: supplierName,
        ),
      ),
    );
  }

  void _handleProductClick(CatalogItem product) async {
    // Find the supplier by matching supplier_name
    // Products in search are only from linked suppliers, so we need to find the supplier
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    Supplier? matchingSupplier;
    
    // First, try to use supplierId from product if available
    if (product.supplierId.isNotEmpty) {
      final supplierName = product.supplierName ?? 'Supplier';
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsumerCatalogScreen(
              supplierId: product.supplierId,
              supplierName: supplierName,
            ),
          ),
        );
      }
      return;
    }
    
    // If supplierId not available, match by supplier_name
    if (product.supplierName != null && product.supplierName!.isNotEmpty) {
      final productSupplierName = product.supplierName!.trim().toLowerCase();
      
      // First try search results
      if (searchProvider.suppliers.isNotEmpty) {
        try {
          matchingSupplier = searchProvider.suppliers.firstWhere(
            (s) {
              final fullName = s.fullName?.trim().toLowerCase() ?? '';
              final companyName = s.companyName.trim().toLowerCase();
              return fullName == productSupplierName || companyName == productSupplierName;
            },
          );
        } catch (e) {
          // Not in search results
        }
      }
      
      // If not found in search results, fetch ALL suppliers and match
      // (Products are only from linked suppliers, so the supplier must exist)
      if (matchingSupplier == null) {
        try {
          final allSuppliers = await LinkRequestService.getAllSuppliers();
          
          // Try exact match first
          try {
            matchingSupplier = allSuppliers.firstWhere(
              (s) {
                final fullName = s.fullName?.trim().toLowerCase() ?? '';
                final companyName = s.companyName.trim().toLowerCase();
                return fullName == productSupplierName || companyName == productSupplierName;
              },
            );
          } catch (e) {
            // Try partial match
            try {
              matchingSupplier = allSuppliers.firstWhere(
                (s) {
                  final fullName = s.fullName?.trim().toLowerCase() ?? '';
                  final companyName = s.companyName.trim().toLowerCase();
                  return fullName.contains(productSupplierName) || 
                         companyName.contains(productSupplierName) ||
                         productSupplierName.contains(fullName) ||
                         productSupplierName.contains(companyName);
                },
              );
            } catch (e2) {
              // Supplier not found
              matchingSupplier = null;
            }
          }
        } catch (e) {
          // Failed to fetch suppliers
          matchingSupplier = null;
        }
      }
    }
    
    // Use found supplier
    if (matchingSupplier != null) {
      final supplierId = matchingSupplier.id;
      final supplierName = matchingSupplier.fullName ?? 
                          matchingSupplier.companyName;
      final finalSupplierName = supplierName.isNotEmpty ? supplierName : (product.supplierName ?? 'Supplier');
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsumerCatalogScreen(
              supplierId: supplierId,
              supplierName: finalSupplierName,
            ),
          ),
        );
      }
    } else {
      // Could not find supplier - show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not find supplier for this product. Supplier: ${product.supplierName ?? "Unknown"}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background matching website
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF20232A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF20232A),
          ),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          // Check if consumer has linked suppliers
          if (!searchProvider.hasLinkedSuppliers) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.link_off,
                      size: 64,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Linked Suppliers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20232A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You need to have at least one accepted link request to search for products and suppliers.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar - matching website design
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search suppliers, products...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDDD)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFDDD), width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF61DAFB), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onFieldSubmitted: (_) => _performSearch(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a search query';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: searchProvider.isLoading ? null : _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF61DAFB), // Light blue matching website
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: searchProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Loading State
                if (searchProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF61DAFB),
                      ),
                    ),
                  ),

                // Error State
                if (!searchProvider.isLoading && searchProvider.errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            searchProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Results
                if (!searchProvider.isLoading &&
                    searchProvider.errorMessage == null &&
                    searchProvider.hasResults) ...[
                  // Suppliers Section
                  if (searchProvider.suppliers.isNotEmpty) ...[
                    _buildSectionTitle('Suppliers (${searchProvider.suppliers.length})'),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchProvider.suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = searchProvider.suppliers[index];
                        return _buildSupplierCard(supplier);
                      },
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Categories Section (if any)
                  if (searchProvider.categories.isNotEmpty) ...[
                    _buildSectionTitle('Categories (${searchProvider.categories.length})'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: searchProvider.categories.map((category) {
                        return _buildCategoryChip(category);
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Products Section
                  if (searchProvider.products.isNotEmpty) ...[
                    _buildSectionTitle('Products (${searchProvider.products.length})'),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate responsive grid based on screen width
                        final screenWidth = constraints.maxWidth;
                        final crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columns on tablets, 2 on phones
                        final spacing = 16.0;
                        final padding = 0.0;
                        final itemWidth = (screenWidth - padding - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                        
                        // Calculate aspect ratio based on estimated content height
                        // Image: 1:1 aspect ratio (itemWidth), Text content: ~80px (compact, no description)
                        // Total height = itemWidth + 80
                        final estimatedHeight = itemWidth + 80;
                        final aspectRatio = itemWidth / estimatedHeight;
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: searchProvider.products.length,
                          itemBuilder: (context, index) {
                            final product = searchProvider.products[index];
                            return _buildProductCard(product);
                          },
                        );
                      },
                    ),
                  ],
                ],

                // Empty State (after search with no results)
                if (!searchProvider.isLoading &&
                    searchProvider.errorMessage == null &&
                    searchProvider.query.isNotEmpty &&
                    !searchProvider.hasResults) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 64, color: Color(0xFF999999)),
                          SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Initial State (before search)
                if (!searchProvider.isLoading &&
                    searchProvider.errorMessage == null &&
                    searchProvider.query.isEmpty) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Column(
                        children: [
                          Icon(Icons.search, size: 64, color: Color(0xFF999999)),
                          SizedBox(height: 16),
                          Text(
                            'Search for products and suppliers',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF20232A),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 2,
          color: const Color(0xFF61DAFB), // Light blue separator
        ),
      ],
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    final name = supplier.fullName ?? supplier.companyName;
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'S';
    
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _handleSupplierClick(supplier),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF61DAFB), Color(0xFF4FCBE4)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Supplier Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20232A),
                      ),
                    ),
                    if (supplier.companyName.isNotEmpty && supplier.fullName != null && supplier.companyName != supplier.fullName) ...[
                      const SizedBox(height: 4),
                      Text(
                        supplier.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      supplier.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDD)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF20232A),
        ),
      ),
    );
  }

  Widget _buildProductCard(CatalogItem product) {
    final imageChar = product.name.isNotEmpty ? product.name[0] : 'P';
    
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _handleProductClick(product),
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Image Placeholder - Fixed height
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      imageChar,
                      style: const TextStyle(
                        fontSize: 40, // Reduced from 48
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
              ),
              // Product Info - Fixed padding, no Flexible to prevent overflow
              Padding(
                padding: const EdgeInsets.all(8.0), // Reduced from 10.0
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name - max 1 line
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13, // Reduced from 15
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20232A),
                        height: 1.1, // Reduced from 1.2
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3), // Reduced from 4
                    // Category
                    Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 11, // Reduced from 12
                        color: Color(0xFF61DAFB),
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 3
                    // Supplier
                    Text(
                      'by ${product.supplierName ?? 'Supplier'}',
                      style: const TextStyle(
                        fontSize: 10, // Reduced from 11
                        color: Color(0xFF666666),
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Reduced from 6
                    // Price - Always show
                    Text(
                      '₸${product.discountedPrice.toStringAsFixed(2)} / ${product.unit}',
                      style: const TextStyle(
                        fontSize: 12, // Reduced from 14
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF20232A),
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // No description to save space
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
