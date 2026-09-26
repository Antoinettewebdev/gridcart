import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefCart = 'cart_items_v1';

class CartService extends ChangeNotifier {
  final Map<int, int> _items = {};

  Map<int, int> get items => Map.unmodifiable(_items);

  int get itemCount => _items.values.fold(0, (sum, qty) => sum + qty);

  bool get isEmpty => _items.isEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefCart);
    _items.clear();
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _items[int.parse(key)] = value as int;
      });
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _items.map((k, v) => MapEntry('$k', v));
    await prefs.setString(_prefCart, jsonEncode(encoded));
  }

  void add(int productId, int quantity) {
    if (quantity <= 0) return;
    _items[productId] = (_items[productId] ?? 0) + quantity;
    notifyListeners();
    _persist();
  }

  void setQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = quantity;
    }
    notifyListeners();
    _persist();
  }

  void buyNow(int productId, int quantity) {
    _items
      ..clear()
      ..[productId] = quantity;
    notifyListeners();
    _persist();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _persist();
  }
}
