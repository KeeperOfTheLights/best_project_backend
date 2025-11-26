import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/link_request_provider.dart';
import '../providers/auth_provider.dart';
import '../models/link_request.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';
import '../services/link_request_service.dart';
import 'orders_screen.dart';

// SupplierCatalogMainScreen - shows Consumer Link Requests similar to website
class SupplierCatalogMainScreen extends StatefulWidget {
  const SupplierCatalogMainScreen({super.key});

  @override
  State<SupplierCatalogMainScreen> createState() => _SupplierCatalogMainScreenState();
}

class _SupplierCatalogMainScreenState extends State<SupplierCatalogMainScreen> {
  String _filterStatus = 'all'; // 'all', 'pending', 'linked', 'rejected', 'blocked'
  String? _actionLoadingId; // Track which request is being processed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LinkRequestProvider>(context, listen: false).loadLinkRequests();
    });
  }

  Future<void> _handleAccept(String requestId) async {
    setState(() {
      _actionLoadingId = requestId;
    });

    try {
      final provider = Provider.of<LinkRequestProvider>(context, listen: false);
      final success = await provider.approveLinkRequest(requestId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link request accepted'),
              backgroundColor: Colors.green,
            ),
          );
          // Provider already reloads the list, but refresh UI to ensure update
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.errorMessage ?? "Failed to accept request"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingId = null;
        });
      }
    }
  }

  Future<void> _handleReject(String requestId) async {
    setState(() {
      _actionLoadingId = requestId;
    });

    try {
      final provider = Provider.of<LinkRequestProvider>(context, listen: false);
      final success = await provider.rejectLinkRequest(requestId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          // Provider already reloads the list, but refresh UI to ensure update
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.errorMessage ?? "Failed to reject request"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingId = null;
        });
      }
    }
  }

  Future<void> _handleBlock(String requestId) async {
    setState(() {
      _actionLoadingId = requestId;
    });

    try {
      await LinkRequestService.blockLinkRequest(requestId);
      final provider = Provider.of<LinkRequestProvider>(context, listen: false);
      await provider.loadLinkRequests();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consumer blocked'),
            backgroundColor: Colors.red,
          ),
        );
        // Refresh UI to ensure update
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingId = null;
        });
      }
    }
  }

  Future<void> _handleUnlink(String linkId) async {
    setState(() {
      _actionLoadingId = linkId;
    });

    try {
      final provider = Provider.of<LinkRequestProvider>(context, listen: false);
      final success = await provider.unlinkConsumer(linkId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Consumer unlinked successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Provider already reloads the list, but refresh UI to ensure update
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${provider.errorMessage ?? "Failed to unlink consumer"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? '';
    final loc = AppLocalizations.of(context);
    
    // Only Owners and Managers can view link requests
    if (userRole != UserRole.owner && userRole != UserRole.manager) {
      return Scaffold(
        backgroundColor: const Color(0xFFBFB7B7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6DEDE),
          title: Text(loc.text('My Catalog')),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: LanguageSwitcher(),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  loc.text('Access Denied'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.text('Only Owners and Managers can view link requests.'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.text('Go to Dashboard')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFBFB7B7), // Light gray background matching website
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6DEDE), // Light pink matching website header
        title: Text(
          loc.text('My Catalog'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: LanguageSwitcher(),
          ),
        ],
      ),
      body: Consumer<LinkRequestProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final allRequests = provider.linkRequests;
          
          // Calculate counts
          final counts = {
            'all': allRequests.length,
            'pending': allRequests.where((r) => r.status == 'pending').length,
            'linked': allRequests.where((r) => r.status == 'linked').length,
            'rejected': allRequests.where((r) => r.status == 'rejected').length,
            'blocked': allRequests.where((r) => r.status == 'blocked').length,
          };

          // Filter requests
          final filteredRequests = _filterStatus == 'all'
              ? allRequests
              : allRequests.where((r) => r.status == _filterStatus).toList();

          return RefreshIndicator(
            onRefresh: () => provider.loadLinkRequests(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    loc.text('Consumer Link Requests'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20232A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.text('Manage consumer connections and access'),
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
                        child: _buildStatCard(
                          counts['pending']!.toString(),
                          loc.text('Pending Requests'),
                          Colors.orange,
                          Icons.hourglass_empty,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          counts['linked']!.toString(),
                          loc.text('Linked Consumers'),
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          counts['rejected']!.toString(),
                          loc.text('Rejected'),
                          Colors.red,
                          Icons.cancel,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          counts['blocked']!.toString(),
                          loc.text('Blocked'),
                          Colors.red[700]!,
                          Icons.block,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab(loc, 'all', counts['all']!, _filterStatus == 'all'),
                        const SizedBox(width: 8),
                        _buildFilterTab(loc, 'pending', counts['pending']!, _filterStatus == 'pending'),
                        const SizedBox(width: 8),
                        _buildFilterTab(loc, 'linked', counts['linked']!, _filterStatus == 'linked'),
                        const SizedBox(width: 8),
                        _buildFilterTab(loc, 'rejected', counts['rejected']!, _filterStatus == 'rejected'),
                        const SizedBox(width: 8),
                        _buildFilterTab(loc, 'blocked', counts['blocked']!, _filterStatus == 'blocked'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Link Request Cards
                  if (filteredRequests.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              loc.text('No requests found'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredRequests.map((request) => _buildRequestCard(request)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(AppLocalizations loc, String status, int count, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF61DAFB) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF61DAFB) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          '${loc.text('${status[0].toUpperCase()}${status.substring(1)}')} ($count)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF20232A),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(LinkRequest request) {
    // Format date as DD.MM.YYYY
    final date = request.createdAt;
    final requestDate = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consumer Name
            Text(
              request.consumerName ?? 'Unknown Consumer',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20232A),
              ),
            ),
            const SizedBox(height: 16),

            // Request Details
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF666666)),
                const SizedBox(width: 8),
                Text(
                  'Request Date: $requestDate',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge, size: 20, color: Color(0xFF9C27B0)),
                const SizedBox(width: 8),
                Text(
                  'Consumer ID: ${request.consumerId}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (request.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _actionLoadingId == request.id
                          ? null
                          : () => _handleAccept(request.id),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(_actionLoadingId == request.id ? 'Processing...' : 'Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _actionLoadingId == request.id
                          ? null
                          : () => _handleReject(request.id),
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(_actionLoadingId == request.id ? 'Processing...' : 'Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _actionLoadingId == request.id
                          ? null
                          : () => _handleBlock(request.id),
                      icon: const Icon(Icons.block, size: 18),
                      label: const Text('Block'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600]!,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (request.status == 'linked') ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to Order Management filtered by consumer ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrdersScreen(
                            isConsumer: false,
                            // Note: We'll filter orders by consumer ID in the OrdersScreen
                            // For now, just navigate - filtering can be added later if needed
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('View Orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF61DAFB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Message functionality - to be implemented later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message functionality coming soon'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _actionLoadingId == request.id
                        ? null
                        : () => _handleUnlink(request.id),
                    icon: const Icon(Icons.link_off, size: 18),
                    label: Text(_actionLoadingId == request.id ? 'Processing...' : 'Unlink'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ] else if (request.status == 'rejected') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Rejected',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (request.status == 'blocked') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.block, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Blocked',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
