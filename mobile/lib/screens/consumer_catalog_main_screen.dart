import 'package:flutter/material.dart';
import '../services/link_request_service.dart';
import '../models/supplier.dart';
import '../models/link_request.dart';
import 'consumer_catalog_screen.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';

// ConsumerCatalogMainScreen - Supplier Connections page matching website design
class ConsumerCatalogMainScreen extends StatefulWidget {
  const ConsumerCatalogMainScreen({super.key});

  @override
  State<ConsumerCatalogMainScreen> createState() =>
      _ConsumerCatalogMainScreenState();
}

class _ConsumerCatalogMainScreenState extends State<ConsumerCatalogMainScreen> {
  List<Supplier> _allSuppliers = [];
  List<LinkRequest> _consumerLinks = [];
  String _filterStatus = 'all';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch all suppliers and consumer links in parallel
      final results = await Future.wait([
        LinkRequestService.getAllSuppliers(),
        LinkRequestService.getLinkRequests(userRole: 'consumer'),
      ]);

      setState(() {
        _allSuppliers = results[0] as List<Supplier>;
        _consumerLinks = results[1] as List<LinkRequest>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Create a map of supplier statuses
  Map<String, String> _getSupplierStatusMap() {
    final Map<String, String> statusMap = {};
    for (var link in _consumerLinks) {
      statusMap[link.supplierId] = link.status;
    }
    return statusMap;
  }

  // Get filtered suppliers based on filter status
  List<SupplierWithStatus> _getFilteredSuppliers() {
    final statusMap = _getSupplierStatusMap();
    final List<SupplierWithStatus> suppliersWithStatus = [];

    for (var supplier in _allSuppliers) {
      final linkStatus = statusMap[supplier.id] ?? 'not_linked';
      suppliersWithStatus.add(SupplierWithStatus(supplier: supplier, status: linkStatus));
    }

    if (_filterStatus == 'all') {
      return suppliersWithStatus;
    } else if (_filterStatus == 'linked') {
      return suppliersWithStatus.where((s) => s.status == 'linked').toList();
    } else if (_filterStatus == 'pending') {
      return suppliersWithStatus.where((s) => s.status == 'pending').toList();
    } else if (_filterStatus == 'not_linked') {
      return suppliersWithStatus.where((s) => s.status == 'not_linked').toList();
    } else if (_filterStatus == 'rejected') {
      return suppliersWithStatus.where((s) => s.status == 'rejected').toList();
    }

    return suppliersWithStatus;
  }

  // Get counts for summary cards
  Map<String, int> _getCounts() {
    final statusMap = _getSupplierStatusMap();
    int linked = 0;
    int pending = 0;
    int available = 0;
    int rejected = 0;

    for (var supplier in _allSuppliers) {
      final linkStatus = statusMap[supplier.id] ?? 'not_linked';
      if (linkStatus == 'linked') {
        linked++;
      } else if (linkStatus == 'pending') {
        pending++;
      } else if (linkStatus == 'not_linked') {
        available++;
      } else if (linkStatus == 'rejected') {
        rejected++;
      }
    }

    return {
      'all': _allSuppliers.length,
      'linked': linked,
      'pending': pending,
      'available': available,
      'rejected': rejected,
    };
  }

  Future<void> _sendLinkRequest(String supplierId) async {
    try {
      await LinkRequestService.sendLinkRequest(supplierId);
      // Reload data after sending request
      await _loadData();
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.text('Link request sent successfully')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.text('Failed to send link request: ')}${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final counts = _getCounts();
    final filteredSuppliers = _getFilteredSuppliers();

    return Scaffold(
      backgroundColor: const Color(0xFFBFB7B7), // Light gray background matching website
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6DEDE), // Light pink matching website header
        title: Text(
          loc.text('Supplier Connections'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${loc.text("Error")}: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text(loc.text('Retry')),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle
                        Text(
                          loc.text('Manage your supplier relationships'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF20232A),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Summary Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                loc.text('Linked'),
                                counts['linked'] ?? 0,
                                Colors.green,
                                Icons.check_circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                loc.text('Pending'),
                                counts['pending'] ?? 0,
                                Colors.orange,
                                Icons.hourglass_empty,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSummaryCard(
                                loc.text('Available'),
                                counts['available'] ?? 0,
                                Colors.blue,
                                Icons.search,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Filter Buttons
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterButton('all', counts['all'] ?? 0, loc),
                            _buildFilterButton('linked', counts['linked'] ?? 0, loc),
                            _buildFilterButton('pending', counts['pending'] ?? 0, loc),
                            _buildFilterButton('not_linked', counts['available'] ?? 0, loc),
                            _buildFilterButton('rejected', counts['rejected'] ?? 0, loc),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Supplier Cards
                        if (filteredSuppliers.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(
                                    loc.text('No suppliers found'),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filteredSuppliers.map((supplierWithStatus) => _buildSupplierCard(
                                supplierWithStatus.supplier,
                                supplierWithStatus.status,
                                loc,
                              )),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF20232A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String status, int count, AppLocalizations loc) {
    final isActive = _filterStatus == status;
    String label;
    if (status == 'all') {
      label = loc.text('All');
    } else if (status == 'linked') {
      label = loc.text('Linked');
    } else if (status == 'pending') {
      label = loc.text('Pending');
    } else if (status == 'not_linked') {
      label = loc.text('not linked');
    } else if (status == 'rejected') {
      label = loc.text('rejected');
    } else {
      label = status.replaceAll('_', ' ');
    }
    
    return InkWell(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF61DAFB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF61DAFB) : Colors.grey,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isActive ? const Color(0xFF20232A) : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier, String status, AppLocalizations loc) {
    // Get initials for logo
    final initials = supplier.companyName.isNotEmpty
        ? supplier.companyName.substring(0, 2).toUpperCase()
        : 'OO';

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier initials/logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Company Name
            Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    supplier.companyName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20232A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Email
            if (supplier.email != null)
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      supplier.email!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Action Button
            if (status == 'not_linked' || status == 'rejected')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _sendLinkRequest(supplier.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF61DAFB), // Light blue matching website
                    foregroundColor: const Color(0xFF20232A), // Black text
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    loc.text('Send Link Request'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (status == 'linked')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsumerCatalogScreen(
                          supplierId: supplier.id,
                          supplierName: supplier.companyName,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF61DAFB),
                    side: const BorderSide(color: Color(0xFF61DAFB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    loc.text('View Catalog'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper class to combine supplier with status
class SupplierWithStatus {
  final Supplier supplier;
  final String status;

  SupplierWithStatus({required this.supplier, required this.status});
}
