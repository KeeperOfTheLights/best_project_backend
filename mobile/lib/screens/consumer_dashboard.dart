import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_service.dart';
import '../utils/localization.dart';
import '../widgets/language_switcher.dart';
import 'search_suppliers_screen.dart';
import 'consumer_catalog_main_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'chat_list_screen.dart';
import 'view_complaints_screen.dart';

class ConsumerDashboard extends StatefulWidget {
  const ConsumerDashboard({super.key});

  @override
  State<ConsumerDashboard> createState() => _ConsumerDashboardState();
}

class _ConsumerDashboardState extends State<ConsumerDashboard> {
  Map<String, dynamic>? _orderStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadOrderStats();
  }

  Future<void> _loadOrderStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats = await OrderService.getConsumerOrderStats();
      setState(() {
        _orderStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;

        _orderStats = {
          'completed_orders': 0,
          'in_progress_orders': 0,
          'cancelled_orders': 0,
          'total_spent': 0.0,
        };
    });
    }
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
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.totalItems == 0) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
            icon: Badge(
              label: Text('${cartProvider.totalItems}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: Text('\$${cartProvider.totalPrice.toStringAsFixed(2)}'),
          );
        },
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
                            loc.text('Welcome back!'),
                            style: const TextStyle(
                          fontSize: 28,
                              fontWeight: FontWeight.bold,
                          color: Color(0xFF20232A),
                            ),
                          ),
                          const SizedBox(height: 8),
                      Text(
                        loc.text("Here's an overview of your order activity."),
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

              _isLoadingStats
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _orderStats == null
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '${_orderStats!['completed_orders']}',
                                loc.text('Completed Orders'),
                                Colors.green,
                                Icons.check_circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                '${_orderStats!['in_progress_orders']}',
                                loc.text('Orders in Process'),
                                Colors.blue,
                                Icons.hourglass_empty,
                              ),
                            ),
                          ],
                        ),
              const SizedBox(height: 12),
              _orderStats != null
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${_orderStats!['cancelled_orders']}',
                            loc.text('Cancelled Orders'),
                            Colors.red,
                            Icons.cancel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '${_orderStats!['total_spent']!.toStringAsFixed(0)} ₸',
                            loc.text('Total Expenses'),
                            Colors.orange,
                            Icons.attach_money,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 24),

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

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          loc.text('Catalog'),
                          Icons.inventory_2,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConsumerCatalogMainScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          loc.text('My Orders'),
                          Icons.shopping_cart,
                          () async {

                            final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                            await orderProvider.loadOrders();
                            
                            if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrdersScreen(isConsumer: true),
                              ),
                            );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          loc.text('Search'),
                          Icons.search,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchSuppliersScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          loc.text('Chat'),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          context,
                          loc.text('My Complaints'),
                          Icons.report_problem,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ViewComplaintsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                        ),
                ],
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
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
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF20232A),
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
    return Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF61DAFB),
            foregroundColor: const Color(0xFF20232A),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



