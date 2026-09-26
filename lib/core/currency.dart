/// Ghana Cedis (GHS / ₵) — default currency for all pricing and checkout.
class Currency {
  Currency._();

  static const String symbol = '₵';
  static const String code = 'GHS';
  static const String label = 'Ghana Cedis';

  /// Approximate USD → GHS rate for demo display (Fake Store API uses USD).
  static const double usdToGhsRate = 12.5;

  static double usdToGhs(double usd) => usd * usdToGhsRate;

  static String format(double amountGhs) {
    final hasCents = (amountGhs * 100).round() % 100 != 0;
    return '$symbol${amountGhs.toStringAsFixed(hasCents ? 2 : 0)}';
  }

  static String formatFromUsd(double usd) => format(usdToGhs(usd));

  static String formatWithCode(double amountGhs) => '${format(amountGhs)} $code';
}
