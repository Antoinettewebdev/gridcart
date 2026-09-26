import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_repository.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;
  String? _homeCategoryFilter;

  List<Product> _products = [];
  final Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  final _repository = ProductRepository();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _repository.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load products. Please try again.';
      });
    }
  }

  void _toggleFavorite(int productId) {
    setState(() {
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _homeCategoryFilter = categoryId;
      _tabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(
        products: _products,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRetry: _fetchProducts,
        favoriteIds: _favoriteIds,
        onFavoriteToggle: _toggleFavorite,
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        initialCategoryId: _homeCategoryFilter,
      ),
      CategoriesTab(
        products: _products,
        onCategorySelected: _selectCategory,
      ),
      ProfileTab(
        products: _products,
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
