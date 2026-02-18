import 'package:mobile_apps/models/product.dart';

class ShoppingList{
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Product> products;

  ShoppingList({required this.id, required this.name, required this.createdAt, required this.products});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map, List<Product> products) {
    return ShoppingList(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      products: products,
    );
  }
}