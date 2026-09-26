import '../core/currency.dart';

class ProductRating {
  const ProductRating({required this.rate, required this.count});

  final double rate;
  final int count;

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.rating,
  });

  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final ProductRating rating;

  double get priceGhs => Currency.usdToGhs(price);

  String get formattedPrice => Currency.formatFromUsd(price);

  String get displayCategory =>
      category.split(' ').map(_titleCaseWord).join(' ');

  static String _titleCaseWord(String word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      rating: ProductRating.fromJson(json['rating'] as Map<String, dynamic>),
    );
  }
}
