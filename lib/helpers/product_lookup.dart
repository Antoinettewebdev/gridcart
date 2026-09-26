import '../models/product.dart';

Product? findProductById(List<Product> products, int id) {
  for (final product in products) {
    if (product.id == id) return product;
  }
  return null;
}

List<({Product product, int qty})> lineItemsFromCart(
  List<Product> products,
  Map<int, int> cart,
) {
  final items = <({Product product, int qty})>[];
  for (final entry in cart.entries) {
    final product = findProductById(products, entry.key);
    if (product != null) {
      items.add((product: product, qty: entry.value));
    }
  }
  return items;
}
