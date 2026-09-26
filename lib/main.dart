import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_scope.dart';
import 'app/theme.dart';
import 'screens/app_bootstrap.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';

const String _prefDarkMode = 'dark_mode';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GridCartApp());
}

class GridCartApp extends StatefulWidget {
  const GridCartApp({super.key});

  @override
  State<GridCartApp> createState() => _GridCartAppState();
}

class _GridCartAppState extends State<GridCartApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final CartService _cart = CartService();
  final OrderService _orders = OrderService();
  bool _servicesReady = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefDarkMode) ?? false;
    await Future.wait([_cart.load(), _orders.load()]);
    if (!mounted) return;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _servicesReady = true;
    });
  }

  Future<void> _toggleTheme() async {
    final next =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setState(() => _themeMode = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefDarkMode, next == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    // AppScope must wrap MaterialApp so pushed routes (cart, checkout, etc.)
    // can access cart and order services via InheritedWidget.
    return AppScope(
      cart: _cart,
      orders: _orders,
      child: MaterialApp(
        title: 'GridCart',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: _themeMode,
        home: _servicesReady
            ? AppBootstrap(
                isDarkMode: _themeMode == ThemeMode.dark,
                onThemeToggle: _toggleTheme,
              )
            : const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }
}
