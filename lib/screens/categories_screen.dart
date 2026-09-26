import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/shop_category.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({
    super.key,
    required this.products,
    required this.onCategorySelected,
  });

  final List<Product> products;
  final ValueChanged<String> onCategorySelected;

  int _countForCategory(ShopCategory category) {
    if (category.id == ShopCategory.all.id) return products.length;
    return products.where(category.matches).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories =
        ShopCategory.catalog.where((c) => c.id != ShopCategory.all.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Browse by category',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Shoes, bags, clothes, electronics, and more — prices in Ghana Cedis (₵).',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.home_rounded,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              title: const Text(
                'View all products',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${products.length} items on Home'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => onCategorySelected(ShopCategory.all.id),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories.elementAt(index);
              final count = _countForCategory(category);

              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onCategorySelected(category.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              theme.colorScheme.primaryContainer,
                          child: Icon(
                            category.icon,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          category.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count items',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
