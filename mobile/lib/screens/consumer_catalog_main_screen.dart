import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/link_request_provider.dart';
import 'consumer_catalog_screen.dart';
import 'search_suppliers_screen.dart';

// ConsumerCatalogMainScreen - shows all approved linked suppliers for catalog browsing
class ConsumerCatalogMainScreen extends StatefulWidget {
  const ConsumerCatalogMainScreen({super.key});

  @override
  State<ConsumerCatalogMainScreen> createState() =>
      _ConsumerCatalogMainScreenState();
}

class _ConsumerCatalogMainScreenState extends State<ConsumerCatalogMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LinkRequestProvider>(context, listen: false)
          .loadLinkRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
      ),
      body: Consumer<LinkRequestProvider>(
        builder: (context, linkProvider, child) {
          if (linkProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final approvedLinks = linkProvider.getApprovedRequests();

          // Show empty state if no approved suppliers
          if (approvedLinks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No catalog available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your catalog will appear here after',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    'your link requests are approved.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchSuppliersScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search Suppliers'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Show list of approved suppliers
          return RefreshIndicator(
            onRefresh: () async {
              await linkProvider.loadLinkRequests();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: approvedLinks.length,
              itemBuilder: (context, index) {
                final link = approvedLinks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: Text(
                        link.supplier?.companyName[0].toUpperCase() ?? 'S',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      link.supplier?.companyName ?? 'Supplier',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (link.supplier?.companyType != null)
                          Text(link.supplier!.companyType!),
                        Text('Linked: ${_formatDate(link.updatedAt ?? link.createdAt)}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsumerCatalogScreen(
                            supplierId: link.supplierId,
                            supplierName:
                                link.supplier?.companyName ?? 'Supplier',
                          ),
                        ),
                      );
                    },
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

