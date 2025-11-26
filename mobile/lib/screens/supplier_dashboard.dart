import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';
import 'supplier_catalog_main_screen.dart';
import 'catalog_management_screen.dart';
import 'orders_screen.dart';
import 'company_management_screen.dart';
import 'chat_list_screen.dart';
import 'complaints_management_screen.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});

  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  Map<String, dynamic>? _orderStats;
  bool _isLoadingStats = true;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _loadOrderStats();
  }

  Future<void> _loadOrderStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      final stats = await OrderService.getSupplierOrderStats();
      setState(() {
        _orderStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
        _statsError = e.toString().replaceAll('Exception: ', '');

        _orderStats = {
          'active_orders': 0,
          'completed_orders': 0,
          'pending_deliveries': 0,
          'total_revenue': 0.0,
        };
      });
    }
  }

  String _getGreeting() {
    final loc = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = authProvider.user?.role ?? '';
    if (role == 'owner') return loc.text('Hello, Owner!');
    if (role == 'manager') return loc.text('Hello, Manager!');
    if (role == 'sales') return loc.text('Hello, Sales Representative!');
    return loc.text('Welcome Back!');
  }

  String _getSubtitle() {
    final loc = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = authProvider.user?.role ?? '';
    if (role == 'sales') {
      return loc.text("Manage your communications and handle customer inquiries.");
    }
    return loc.text("Here's an overview of your performance and current activity.");
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFBFB7B7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6DEDE),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'DV',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: LanguageSwitcher(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await authProvider.logout();
            },
            tooltip: loc.text('Sign Out'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrderStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getSubtitle(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF20232A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (authProvider.user?.role != 'sales') ...[
                _isLoadingStats
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _orderStats == null
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      '${_orderStats!['active_orders']}',
                                      loc.text('Active Orders'),
                                      const Color(0xFF61DAFB),
                                      Icons.shopping_cart,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      '${_orderStats!['completed_orders']}',
                                      loc.text('Completed Orders'),
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
                                      '${_orderStats!['pending_deliveries']}',
                                      loc.text('Pending Deliveries'),
                                      Colors.orange,
                                      Icons.local_shipping,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      '${_orderStats!['total_revenue']!.toStringAsFixed(0)} ₸',
                                      loc.text('Total Revenue'),
                                      const Color(0xFF9C27B0),
                                      Icons.attach_money,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                if (_statsError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statsError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadOrderStats,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],

              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    color: const Color(0xFF20232A),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loc.text('Quick Actions'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20232A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),


              Builder(
                builder: (context) {
                  final userRole = authProvider.user?.role ?? '';
                  final isOwner = userRole == UserRole.owner;
                  final isManager = userRole == UserRole.manager;
                  final isCatalogManager = isOwner || isManager;

                  return Column(
                    children: [

                      if (isCatalogManager) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionButton(
                                context,
                                loc.text('My Catalog'),
                                Icons.inventory_2,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SupplierCatalogMainScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionButton(
                                context,
                                loc.text('Products'),
                                Icons.category,
                                () {
                                  final userId = authProvider.user?.id ?? '';
                                  final userName = authProvider.user?.name ?? 'Supplier';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CatalogManagementScreen(
                                        supplierId: userId,
                                        supplierName: userName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      Row(
                        children: [
                          Expanded(
                              child: _buildQuickActionButton(
                                context,
                                loc.text('Order Management'),
                              Icons.shopping_cart,
                              () async {

                                final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                                await orderProvider.loadOrders();
                                
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OrdersScreen(isConsumer: false),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),

                          if (isOwner) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickActionButton(
                                context,
                                loc.text('Company Management'),
                                Icons.business,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CompanyManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ] else if (isCatalogManager) ...[

                            const SizedBox(width: 12),
                            const Expanded(child: SizedBox()),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                              child: _buildQuickActionButton(
                                context,
                                loc.text('Chats'),
                              Icons.chat,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChatListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildQuickActionButton(
                                context,
                                loc.text('Complaints'),
                              Icons.report_problem,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ComplaintsManagementScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
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

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF61DAFB),
                size: 24,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF20232A),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
