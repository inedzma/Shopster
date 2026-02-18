import 'package:mobile_apps/models/product.dart';

class PurchaseHistory {
  final String id;
  final Product product;
  final double quantity;
  final double price;
  final DateTime date;

  PurchaseHistory({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': product.id,
      'quantity': quantity,
      'price': price,
      'date': date.toIso8601String(), // Spremanje datuma kao String
    };
  }

  factory PurchaseHistory.fromMap(Map<String, dynamic> map, Product product) {
    return PurchaseHistory(
      id: map['id'],
      product: product,
      quantity: map['quantity'].toDouble(),
      price: map['price'].toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}