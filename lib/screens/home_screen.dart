import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/navigation.dart';
import '../models/product.dart';
import '../models/shop_category.dart';
import '../widgets/common_widgets.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.favoriteIds,
    required this.onFavoriteToggle,
    required this.isDarkMode,
    required this.onThemeToggle,
    this.initialCategoryId,
  });

  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Set<int> favoriteIds;
  final void Function(int productId) onFavoriteToggle;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final String? initialCategoryId;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? ShopCategory.all.id;
  }

  @override
  void didUpdateWidget(HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategoryId != null &&
        widget.initialCategoryId != oldWidget.initialCategoryId) {
      _selectedCategoryId = widget.initialCategoryId!;
    }
  }

  ShopCategory get _selectedCategory => ShopCategory.catalog.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => ShopCategory.all,
      );

  List<Product> get _filteredProducts {
    var list = widget.products;
    final category = _selectedCategory;
    if (category.id != ShopCategory.all.id) {
      list = list.where(category.matches).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

  void _openProductDetail(Product product) {
    Navigator.push<void>(
      context,
      buildSlideRoute(
        ProductDetailScreen(
          product: product,
          products: widget.products,
          isFavorite: widget.favoriteIds.contains(product.id),
          onFavoriteToggle: () => widget.onFavoriteToggle(product.id),
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.push<void>(
      context,
      buildSlideRoute(CartScreen(products: widget.products)),
    );
  }

  int _gridColumnCount(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.cart,
      builder: (context, _) {
        final cartCount = scope.cart.itemCount;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'GridCart',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                onPressed: widget.onThemeToggle,
                tooltip: widget.isDarkMode ? 'Light mode' : 'Dark mode',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    widget.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(widget.isDarkMode),
                  ),
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: _openCart,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: 'Cart',
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: CartBadge(count: cartCount),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _HomePromoBanner(theme: theme),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ShopCategory.catalog.map((cat) {
                    return CategoryChip(
                      label: cat.label,
                      icon: cat.icon,
                      selected: _selectedCategoryId == cat.id,
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search shoes, bags, clothes…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(child: _buildBody(theme)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading products…'),
          ],
        ),
      );
    }

    if (widget.errorMessage != null) {
      return ErrorView(
        message: widget.errorMessage!,
        onRetry: widget.onRetry,
      );
    }

    final products = _filteredProducts;

    if (products.isEmpty) {
      return EmptyStateView(
        icon: _searchQuery.isEmpty
            ? Icons.inventory_2_outlined
            : Icons.search_off_rounded,
        title: _searchQuery.isEmpty ? 'No products in category' : 'No matches',
        subtitle: _searchQuery.isEmpty
            ? 'Try another category or check back later.'
            : 'Try a different search term.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = _gridColumnCount(constraints.maxWidth);
        final isWide = constraints.maxWidth >= 600;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 4, isWide ? 24 : 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedCategory.label == 'All'
                            ? 'All products'
                            : _selectedCategory.label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${products.length} items',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isWide ? 0.72 : 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      isFavorite: widget.favoriteIds.contains(product.id),
                      onTap: () => _openProductDetail(product),
                      onFavoriteTap: () => widget.onFavoriteToggle(product.id),
                      onAddToCart: () {
                        AppScope.of(context).cart.add(product.id, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('Added ${product.title} to cart'),
                            action: SnackBarAction(
                              label: 'View cart',
                              onPressed: _openCart,
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }
}

class _HomePromoBanner extends StatelessWidget {
  const _HomePromoBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover quality products',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Prices in Ghana Cedis',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'GHS (₵) · Mobile Money & card checkout',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
