import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';

const String _prefOrders = 'purchase_orders_v1';

class OrderService extends ChangeNotifier {
  final List<PurchaseOrder> _orders = [];

  List<PurchaseOrder> get orders => List.unmodifiable(_orders);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefOrders);
    _orders.clear();
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _orders.addAll(
        list.map((e) => PurchaseOrder.fromJson(e as Map<String, dynamic>)),
      );
      _orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    }
    notifyListeners();
  }

  Future<void> addOrder(PurchaseOrder order) async {
    _orders.insert(0, order);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefOrders,
      jsonEncode(_orders.map((o) => o.toJson()).toList()),
    );
    notifyListeners();
  }
}
