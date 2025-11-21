import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/link_request_provider.dart';
import '../utils/constants.dart';
import 'manage_link_requests_screen.dart';
import 'orders_screen.dart';
import 'chat_list_screen.dart';
import 'staff_management_screen.dart';
import 'sales_management_screen.dart';

// SupplierDashboard - the main screen for suppliers after login
class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  @override
  void initState() {
    super.initState();
    // Load link requests when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LinkRequestProvider>(context, listen: false)
          .loadLinkRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<LinkRequestProvider>(
        builder: (context, linkProvider, child) {
          final pendingRequests = linkProvider.getPendingRequests();

          return RefreshIndicator(
            onRefresh: () async {
              await linkProvider.loadLinkRequests();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${authProvider.user?.name ?? 'Supplier'}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authProvider.user?.companyName ?? 'Your Company',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (userRole != UserRole.supplier)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Chip(
                                label: Text(
                                  userRole.toUpperCase(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue.shade100,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pending Requests',
                          pendingRequests.length.toString(),
                          Colors.orange,
                          Icons.pending,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'New Orders',
                          '0', // TODO: Get from orders provider
                          Colors.blue,
                          Icons.shopping_cart,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Open Complaints',
                          '0', // TODO: Get from complaints provider
                          Colors.red,
                          Icons.report_problem,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Active Links',
                          linkProvider.getApprovedRequests().length.toString(),
                          Colors.green,
                          Icons.link,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.inventory,
                          title: 'Catalog',
                          color: Colors.blue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Catalog management coming soon'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.shopping_cart,
                          title: 'Orders',
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrdersScreen(isConsumer: false),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          icon: Icons.link,
                          title: 'Link Requests',
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ManageLinkRequestsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.chat,
                              title: 'Chats',
                              color: Colors.purple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChatListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                    ],
                  ),
                   // Sales Management (Owners and Managers only)
                   if (userRole == UserRole.owner || userRole == UserRole.manager) ...[
                     const SizedBox(height: 12),
                     Row(
                       children: [
                         Expanded(
                           child: _buildActionCard(
                             context,
                             icon: Icons.business,
                             title: 'Sales Management',
                             color: Colors.teal,
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => const SalesManagementScreen(),
                                 ),
                               );
                             },
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Container(), // Empty space for alignment
                         ),
                       ],
                     ),
                   ],
                   // Staff Management (Owners only)
                   if (userRole == UserRole.owner) ...[
                     const SizedBox(height: 12),
                     Row(
                       children: [
                         Expanded(
                           child: _buildActionCard(
                             context,
                             icon: Icons.people,
                             title: 'Staff Management',
                             color: Colors.indigo,
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => const StaffManagementScreen(),
                                 ),
                               );
                             },
                           ),
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Container(), // Empty space for alignment
                         ),
                       ],
                     ),
                   ],
                  const SizedBox(height: 24),

                  // Pending Link Requests Section
                  if (pendingRequests.isNotEmpty &&
                      (userRole == UserRole.owner ||
                          userRole == UserRole.manager)) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pending Link Requests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ManageLinkRequestsScreen(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pendingRequests.take(3).map((request) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.pending, color: Colors.white),
                            ),
                            title: Text(
                              request.consumer?.name ?? 'Consumer',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              request.consumer?.businessName ?? '',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    final provider =
                                        Provider.of<LinkRequestProvider>(
                                      context,
                                      listen: false,
                                    );
                                    await provider.approveLinkRequest(request.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request approved'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: 'Approve',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    final provider =
                                        Provider.of<LinkRequestProvider>(
                                      context,
                                      listen: false,
                                    );
                                    await provider.rejectLinkRequest(request.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request rejected'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: 'Reject',
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
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
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
