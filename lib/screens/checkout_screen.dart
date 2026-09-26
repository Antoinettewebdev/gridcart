import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../core/currency.dart';
import '../helpers/product_lookup.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../widgets/common_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.products,
    required this.cart,
    this.buyNowMode = false,
  });

  final List<Product> products;
  final Map<int, int> cart;
  final bool buyNowMode;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Kwame Mensah');
  final _phoneController = TextEditingController(text: '024 123 4567');
  final _addressController = TextEditingController(
    text: '12 Independence Ave, Accra, Ghana',
  );

  String _paymentMethod = 'Mobile Money';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  List<({Product product, int qty})> get _lineItems =>
      lineItemsFromCart(widget.products, widget.cart);

  double get _totalGhs {
    var sum = 0.0;
    for (final item in _lineItems) {
      sum += item.product.priceGhs * item.qty;
    }
    return sum;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate() || _lineItems.isEmpty) return;

    setState(() => _isProcessing = true);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final scope = AppScope.of(context);
    final orderId = 'GC-${DateTime.now().millisecondsSinceEpoch}';
    final order = PurchaseOrder(
      id: orderId,
      placedAt: DateTime.now(),
      totalGhs: _totalGhs,
      customerName: _nameController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      items: _lineItems
          .map(
            (e) => OrderLineItem(
              productId: e.product.id,
              title: e.product.title,
              imageUrl: e.product.imageUrl,
              quantity: e.qty,
              unitPriceGhs: e.product.priceGhs,
            ),
          )
          .toList(),
    );

    await scope.orders.addOrder(order);
    scope.cart.clear();

    if (!mounted) return;
    setState(() => _isProcessing = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
        title: const Text('Order placed!'),
        content: Text(
          'Thank you, ${order.customerName}. Your order $orderId for '
          '${order.formattedTotal} has been confirmed. We will deliver to '
          '${order.deliveryAddress}.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _lineItems;

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const EmptyStateView(
          icon: Icons.shopping_cart_outlined,
          title: 'Nothing to checkout',
          subtitle: 'Add items to your cart first.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.buyNowMode ? 'Buy Now' : 'Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Order summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                  title: Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('Qty ${item.qty}'),
                  trailing: Text(
                    Currency.format(item.product.priceGhs * item.qty),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${Currency.code})',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  Currency.format(_totalGhs),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Delivery details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().length < 9 ? 'Enter a valid phone' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Delivery address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your address' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Payment method',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Mobile Money', 'Card', 'Cash on delivery'].map((method) {
                final selected = _paymentMethod == method;
                return ChoiceChip(
                  label: Text(method),
                  selected: selected,
                  onSelected: (_) => setState(() => _paymentMethod = method),
                );
              }).toList(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _isProcessing ? null : _placeOrder,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _isProcessing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Pay ${Currency.format(_totalGhs)}'),
            ),
          ),
        ),
      ),
    );
  }
}
