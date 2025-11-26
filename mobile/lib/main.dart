import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/link_request_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/order_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/search_provider.dart';
import 'providers/language_provider.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/consumer_dashboard.dart';
import 'screens/supplier_dashboard.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => LinkRequestProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StaffProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SupplierProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            title: 'DV',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
              useMaterial3: true,
            ),
            locale: languageProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ru'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          final role = authProvider.user?.role ?? '';
          if (role == UserRole.consumer) {
            return const ConsumerDashboard();
          } else if (role == UserRole.supplier ||
                   role == UserRole.owner ||
                   role == UserRole.manager ||
                   role == UserRole.sales) {
            return const SupplierDashboard();
          }
        }

        return const LoginScreen();
      },
    );
  }
}
