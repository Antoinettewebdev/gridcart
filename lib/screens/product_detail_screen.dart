import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/navigation.dart';
import '../models/product.dart';
import '../widgets/common_widgets.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.products,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final List<Product> products;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isFavorite;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    widget.onFavoriteToggle();
    setState(() => _isFavorite = !_isFavorite);
  }

  void _openCheckout({required bool buyNow}) {
    final scope = AppScope.of(context);
    final cartSnapshot = <int, int>{};

    if (buyNow) {
      scope.cart.buyNow(widget.product.id, _quantity);
      cartSnapshot[widget.product.id] = _quantity;
    } else {
      scope.cart.add(widget.product.id, _quantity);
      cartSnapshot.addAll(scope.cart.items);
    }

    Navigator.push<void>(
      context,
      buildSlideRoute(
        CheckoutScreen(
          products: widget.products,
          cart: cartSnapshot,
          buyNowMode: buyNow,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth >= 720
              ? _buildWideLayout(context)
              : _buildCompactLayout(context);
        },
      ),
      bottomNavigationBar: _buildActionBar(context),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildImageAppBar(context, expandedHeight: 320),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildDetailsContent(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Hero(
                        tag: 'product-image-${widget.product.id}',
                        child: ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: _imageError,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: _buildDetailsContent(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildImageAppBar(
    BuildContext context, {
    required double expandedHeight,
  }) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.surface,
      leading: _buildBackButton(context),
      actions: [_buildFavoriteButton()],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Hero(
          tag: 'product-image-${widget.product.id}',
          child: ColoredBox(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: _imageError,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoChip(
              icon: Icons.category_outlined,
              label: product.displayCategory,
            ),
            InfoChip(icon: Icons.tag_outlined, label: 'ID ${product.id}'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.25,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        RatingRow(rate: product.rating.rate, count: product.rating.count),
        const SizedBox(height: 12),
        Text(
          product.formattedPrice,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Quantity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        QuantitySelector(
          quantity: _quantity,
          onDecrement: () {
            if (_quantity > 1) setState(() => _quantity--);
          },
          onIncrement: () => setState(() => _quantity++),
        ),
        const SizedBox(height: 20),
        Divider(color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 16),
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  AppScope.of(context)
                      .cart
                      .add(widget.product.id, _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Added $_quantity × ${widget.product.title}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Add to Cart'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  _openCheckout(buyNow: true);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _buildBackButton(context),
        const Spacer(),
        _buildFavoriteButton(),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  Widget _buildFavoriteButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton.filled(
        onPressed: _toggleFavorite,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(_isFavorite),
            color: _isFavorite ? Colors.redAccent : null,
          ),
        ),
      ),
    );
  }

  Widget _imageError(BuildContext context, Object error, StackTrace? stack) {
    return const Center(
      child: Icon(Icons.broken_image_outlined, size: 64),
    );
  }
}
