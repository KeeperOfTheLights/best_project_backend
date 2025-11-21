import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/link_request_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/order_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/supplier_provider.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/consumer_dashboard.dart';
import 'screens/supplier_dashboard.dart';
import 'utils/constants.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service (to load saved token)
  await StorageService.init();
  
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider - manages login state
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        // LinkRequestProvider - manages link requests
        ChangeNotifierProvider(
          create: (_) => LinkRequestProvider(),
        ),
        // CartProvider - manages shopping cart
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        // CatalogProvider - manages catalog items
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(),
        ),
                // OrderProvider - manages orders
                ChangeNotifierProvider(
                  create: (_) => OrderProvider(),
                ),
                // ChatProvider - manages chat
                ChangeNotifierProvider(
                  create: (_) => ChatProvider(),
                ),
                // StaffProvider - manages staff
                ChangeNotifierProvider(
                  create: (_) => StaffProvider(),
                ),
                // SupplierProvider - manages suppliers (Sales Management)
                ChangeNotifierProvider(
                  create: (_) => SupplierProvider(),
                ),
              ],
      child: MaterialApp(
        title: 'Supplier-Consumer Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        // Home is determined by AuthWrapper which checks if user is logged in
        home: const AuthWrapper(),
      ),
    );
  }
}

// AuthWrapper - decides which screen to show based on login status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking authentication
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in, show appropriate dashboard
        if (authProvider.isAuthenticated) {
          final role = authProvider.user?.role ?? '';
          
          // Show Consumer dashboard for consumers
          if (role == UserRole.consumer) {
            return const ConsumerDashboard();
          }
          // Show Supplier dashboard for suppliers (and their roles: owner, manager, sales)
          else if (role == UserRole.supplier ||
                   role == UserRole.owner ||
                   role == UserRole.manager ||
                   role == UserRole.sales) {
            return const SupplierDashboard();
          }
        }

        // If not logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
