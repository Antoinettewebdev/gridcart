import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gridcart/app/app_scope.dart';
import 'package:gridcart/main.dart';
import 'package:gridcart/services/cart_service.dart';
import 'package:gridcart/services/order_service.dart';

void main() {
  testWidgets('App renders bootstrap loading state', (WidgetTester tester) async {
    await tester.pumpWidget(const GridCartApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Cart service adds items', (WidgetTester tester) async {
    final cart = CartService();
    final orders = OrderService();

    await tester.pumpWidget(
      AppScope(
        cart: cart,
        orders: orders,
        child: const MaterialApp(
          home: Scaffold(body: Text('test')),
        ),
      ),
    );

    cart.add(1, 2);
    await tester.pump();

    expect(cart.itemCount, 2);
    expect(cart.items[1], 2);
  });
}
