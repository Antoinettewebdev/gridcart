import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/navigation.dart';
import '../core/currency.dart';
import '../helpers/product_lookup.dart';
import '../models/product.dart';
import '../widgets/common_widgets.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.products,
  });

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final cart = scope.cart;

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final entries = cart.items.entries.toList();
        final theme = Theme.of(context);

        double totalGhs = 0;
        for (final entry in entries) {
          final product = findProductById(products, entry.key);
          if (product != null) {
            totalGhs += product.priceGhs * entry.value;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Cart'),
            actions: [
              if (entries.isNotEmpty)
                TextButton(
                  onPressed: cart.clear,
                  child: const Text('Clear'),
                ),
            ],
          ),
          body: entries.isEmpty
              ? const EmptyStateView(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Your cart is empty',
                  subtitle: 'Add items from the shop to get started.',
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final product = findProductById(products, entry.key);
                          if (product == null) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 72,
                                        height: 72,
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.formattedPrice,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        QuantitySelector(
                                          quantity: entry.value,
                                          compact: true,
                                          onDecrement: () => cart.setQuantity(
                                            entry.key,
                                            entry.value - 1,
                                          ),
                                          onIncrement: () => cart.setQuantity(
                                            entry.key,
                                            entry.value + 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Total (${Currency.code})',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    Currency.format(totalGhs),
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: entries.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push<void>(
                                        context,
                                        buildSlideRoute(
                                          CheckoutScreen(
                                            products: products,
                                            cart: Map<int, int>.from(
                                              cart.items,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('Checkout'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

}
