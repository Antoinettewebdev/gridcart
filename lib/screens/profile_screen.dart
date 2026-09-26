import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/navigation.dart';
import '../core/currency.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../widgets/common_widgets.dart';
import 'cart_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.products,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final List<Product> products;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.orders,
      builder: (context, _) {
        final orderCount = scope.orders.orders.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kwame Mensah',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Accra, Ghana',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onThemeToggle,
                        icon: Icon(
                          isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _ProfileMenuItem(
                icon: Icons.mail_outline_rounded,
                title: 'Messages',
                subtitle: '3 unread conversations',
                onTap: () => _openSubPage(
                  context,
                  const MessagesScreen(),
                ),
              ),
              _ProfileMenuItem(
                icon: Icons.rate_review_outlined,
                title: 'Reviews',
                subtitle: 'Your product ratings',
                onTap: () => _openSubPage(
                  context,
                  const ReviewsScreen(),
                ),
              ),
              _ProfileMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Orders',
                subtitle: orderCount == 0
                    ? 'No orders yet'
                    : '$orderCount order${orderCount == 1 ? '' : 's'}',
                onTap: () => _openSubPage(
                  context,
                  const OrdersScreen(),
                ),
              ),
              _ProfileMenuItem(
                icon: Icons.history_rounded,
                title: 'Purchase History',
                subtitle: 'Past purchases & receipts',
                onTap: () => _openSubPage(
                  context,
                  const PurchaseHistoryScreen(),
                ),
              ),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: scope.cart,
                builder: (context, _) {
                  if (scope.cart.isEmpty) return const SizedBox.shrink();
                  return FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        buildSlideRoute(
                          CartScreen(products: products),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(
                      'View cart (${scope.cart.itemCount} items)',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSubPage(BuildContext context, Widget page) {
    Navigator.push<void>(context, buildSlideRoute(page));
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const _messages = [
    ('GridCart Support', 'Your order is on the way!', '2h ago'),
    ('Delivery Team', 'We will arrive between 2–4 PM today.', '1d ago'),
    ('Promotions', 'Weekend sale: up to 20% off in Accra.', '3d ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final (name, body, time) = _messages[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.storefront)),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(body),
              trailing: Text(
                time,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  static const _reviews = [
    ('Fjallraven Backpack', 4.5),
    ('Mens Casual Premium Slim Fit', 4.0),
    ('Gold Plated Princess Ring', 5.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final (title, rating) = _reviews[index];
          return Card(
            child: ListTile(
              title: Text(title),
              subtitle: RatingRow(rate: rating, count: 12 + index * 3),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review editing coming soon'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).orders;

    return ListenableBuilder(
      listenable: orders,
      builder: (context, _) {
        final list = orders.orders;

        if (list.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Orders')),
            body: const EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Complete a checkout to see your orders here.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Orders')),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _OrderCard(order: list[index]),
          ),
        );
      },
    );
  }
}

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = AppScope.of(context).orders;

    return ListenableBuilder(
      listenable: orderService,
      builder: (context, _) {
        final orders = orderService.orders;

        if (orders.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Purchase History')),
            body: const EmptyStateView(
              icon: Icons.history_rounded,
              title: 'No purchase history',
              subtitle: 'Your completed checkouts will appear here.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Purchase History')),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.receipt_rounded),
                  title: Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_formatDate(order.placedAt)} · ${order.formattedTotal}',
                  ),
                  children: order.items
                      .map(
                        (item) => ListTile(
                          dense: true,
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('Qty ${item.quantity}'),
                          trailing: Text(Currency.format(item.lineTotal)),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final PurchaseOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(order.status),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${order.items.length} item(s) · ${order.formattedTotal}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.deliveryAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
