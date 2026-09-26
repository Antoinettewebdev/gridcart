import '../core/currency.dart';

class OrderLineItem {
  const OrderLineItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.quantity,
    required this.unitPriceGhs,
  });

  final int productId;
  final String title;
  final String imageUrl;
  final int quantity;
  final double unitPriceGhs;

  double get lineTotal => unitPriceGhs * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'unitPriceGhs': unitPriceGhs,
      };

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      productId: json['productId'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      quantity: json['quantity'] as int,
      unitPriceGhs: (json['unitPriceGhs'] as num).toDouble(),
    );
  }
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.placedAt,
    required this.items,
    required this.totalGhs,
    required this.customerName,
    required this.deliveryAddress,
    required this.phone,
    this.status = 'Delivered',
  });

  final String id;
  final DateTime placedAt;
  final List<OrderLineItem> items;
  final double totalGhs;
  final String customerName;
  final String deliveryAddress;
  final String phone;
  final String status;

  String get formattedTotal => Currency.format(totalGhs);

  Map<String, dynamic> toJson() => {
        'id': id,
        'placedAt': placedAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'totalGhs': totalGhs,
        'customerName': customerName,
        'deliveryAddress': deliveryAddress,
        'phone': phone,
        'status': status,
      };

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String,
      placedAt: DateTime.parse(json['placedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalGhs: (json['totalGhs'] as num).toDouble(),
      customerName: json['customerName'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String? ?? 'Delivered',
    );
  }
}
