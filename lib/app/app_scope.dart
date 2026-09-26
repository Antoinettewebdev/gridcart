import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import '../services/order_service.dart';

class AppScope extends InheritedNotifier<CartService> {
  const AppScope({
    super.key,
    required this.cart,
    required this.orders,
    required super.child,
  }) : super(notifier: cart);

  final CartService cart;
  final OrderService orders;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      cart != oldWidget.cart || orders != oldWidget.orders;
}
