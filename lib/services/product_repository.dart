import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

const String productsApiUrl = 'https://fakestoreapi.com/products';

class ProductRepository {
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse(productsApiUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _fallbackProducts;
    }
  }

  /// Local catalog used when the API is unreachable so cart/checkout still work.
  static final List<Product> _fallbackProducts = [
    Product(
      id: 1,
      title: 'Fjallraven Backpack',
      description:
          'Your perfect pack for everyday use and walks in the forest.',
      imageUrl: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
      price: 109.95,
      category: "men's clothing",
      rating: const ProductRating(rate: 3.9, count: 120),
    ),
    Product(
      id: 2,
      title: 'Mens Casual Premium Slim Fit',
      description: 'Slim-fitting style, contrast raglan long sleeve.',
      imageUrl:
          'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
      price: 22.3,
      category: "men's clothing",
      rating: const ProductRating(rate: 4.1, count: 259),
    ),
    Product(
      id: 3,
      title: 'Mens Cotton Jacket',
      description: 'Great outerwear jackets for Spring/Autumn/Winter.',
      imageUrl: 'https://fakestoreapi.com/img/71li7jahPL._AC_UL640_QL65_ML3_.jpg',
      price: 55.99,
      category: "men's clothing",
      rating: const ProductRating(rate: 4.7, count: 500),
    ),
    Product(
      id: 4,
      title: 'Mens Casual Slim Fit',
      description: 'The color could be slightly different between on the screen.',
      imageUrl: 'https://fakestoreapi.com/img/71YXzeHusL._AC_UY879_.jpg',
      price: 15.99,
      category: "men's clothing",
      rating: const ProductRating(rate: 2.1, count: 430),
    ),
    Product(
      id: 5,
      title: 'Gold Plated Princess Ring',
      description: 'Classic Created Wedding Engagement Solitaire Diamond Ring.',
      imageUrl: 'https://fakestoreapi.com/img/61U7T1koQqL._AC_SX679_.jpg',
      price: 695,
      category: 'jewelry',
      rating: const ProductRating(rate: 4.6, count: 400),
    ),
    Product(
      id: 6,
      title: 'Solid Gold Petite Micropave',
      description: 'Satisfaction Guaranteed. Return or exchange any order.',
      imageUrl: 'https://fakestoreapi.com/img/61sbMiUnoGL._AC_UL640_QL65_ML3_.jpg',
      price: 168,
      category: 'jewelry',
      rating: const ProductRating(rate: 3.9, count: 70),
    ),
    Product(
      id: 7,
      title: 'White Gold Plated Princess',
      description: 'Classic Created Wedding Engagement Solitaire Diamond Ring.',
      imageUrl: 'https://fakestoreapi.com/img/71YAIFU48IL._AC_UL640_QL65_ML3_.jpg',
      price: 9.99,
      category: 'jewelry',
      rating: const ProductRating(rate: 3, count: 400),
    ),
    Product(
      id: 8,
      title: 'Pierced Owl Rose Gold Earrings',
      description: 'Rose gold plated double flared tunnel plug earrings.',
      imageUrl: 'https://fakestoreapi.com/img/51UDEzMJVpL._AC_UL640_QL65_ML3_.jpg',
      price: 10.99,
      category: 'jewelry',
      rating: const ProductRating(rate: 1.9, count: 100),
    ),
    Product(
      id: 9,
      title: 'WD 2TB Elements Portable Hard Drive',
      description: 'USB 3.0 and USB 2.0 Compatibility. Fast data transfers.',
      imageUrl: 'https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_.jpg',
      price: 64,
      category: 'electronics',
      rating: const ProductRating(rate: 3.3, count: 203),
    ),
    Product(
      id: 10,
      title: 'SanDisk SSD PLUS 1TB Internal SSD',
      description: 'Easy upgrade for faster boot up, shutdown, application load.',
      imageUrl: 'https://fakestoreapi.com/img/61fIPEpChML._AC_SY879_.jpg',
      price: 109,
      category: 'electronics',
      rating: const ProductRating(rate: 2.9, count: 470),
    ),
  ];
}
