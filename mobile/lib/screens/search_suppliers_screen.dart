import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/link_request_provider.dart';
import '../models/supplier.dart';

// SearchSuppliersScreen - allows consumers to search and send link requests to suppliers
class SearchSuppliersScreen extends StatefulWidget {
  const SearchSuppliersScreen({super.key});

  @override
  State<SearchSuppliersScreen> createState() => _SearchSuppliersScreenState();
}

class _SearchSuppliersScreenState extends State<SearchSuppliersScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) {
      return;
    }
    _hasSearched = true;
    Provider.of<LinkRequestProvider>(context, listen: false)
        .searchSuppliers(_searchController.text.trim());
  }

  Future<void> _sendLinkRequest(Supplier supplier) async {
    final provider = Provider.of<LinkRequestProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Link Request'),
        content: Text('Send a link request to ${supplier.companyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.sendLinkRequest(supplier.id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link request sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to send link request'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Suppliers'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by supplier name...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: Consumer<LinkRequestProvider>(
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
                        Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!_hasSearched) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Search for suppliers by name',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.suppliers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No suppliers found',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: provider.suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = provider.suppliers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.business),
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
                            if (supplier.address != null)
                              Text('Address: ${supplier.address}'),
                            if (supplier.phone != null)
                              Text('Phone: ${supplier.phone}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _sendLinkRequest(supplier),
                          child: const Text('Send Request'),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




