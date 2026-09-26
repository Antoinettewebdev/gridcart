import 'package:flutter/material.dart';

import 'product.dart';

class ShopCategory {
  const ShopCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.apiCategories = const [],
    this.keywords = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final List<String> apiCategories;
  final List<String> keywords;

  bool matches(Product product) {
    if (apiCategories.contains(product.category)) return true;
    if (keywords.isEmpty) return false;
    final haystack =
        '${product.title} ${product.description}'.toLowerCase();
    return keywords.any(haystack.contains);
  }

  static const all = ShopCategory(
    id: 'all',
    label: 'All',
    icon: Icons.apps_rounded,
  );

  static const List<ShopCategory> catalog = [
    all,
    ShopCategory(
      id: 'clothes',
      label: 'Clothes',
      icon: Icons.checkroom_rounded,
      apiCategories: ["men's clothing", "women's clothing"],
      keywords: ['shirt', 'jacket', 'coat', 'dress', 'clothing'],
    ),
    ShopCategory(
      id: 'shoes',
      label: 'Shoes',
      icon: Icons.directions_run_rounded,
      keywords: ['shoe', 'sneaker', 'boot', 'footwear'],
    ),
    ShopCategory(
      id: 'bags',
      label: 'Bags',
      icon: Icons.shopping_bag_rounded,
      keywords: ['bag', 'backpack', 'purse', 'handbag', 'luggage'],
    ),
    ShopCategory(
      id: 'electronics',
      label: 'Electronics',
      icon: Icons.devices_rounded,
      apiCategories: ['electronics'],
    ),
    ShopCategory(
      id: 'jewelry',
      label: 'Jewelry',
      icon: Icons.diamond_rounded,
      apiCategories: ['jewelry'],
      keywords: ['ring', 'necklace', 'bracelet', 'gold'],
    ),
  ];
}
