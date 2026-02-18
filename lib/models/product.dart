import 'package:mobile_apps/models/unit.dart';

import 'category.dart';

class Product {
  final String id;
  final String name;
  final Category category;
  final Unit unit;

  Product({required this.id, required this.name, required this.category, required this.unit});

  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'name': name,
      'category_id': category.id,
      'unit_id': unit.id,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, Category cat, Unit u) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: cat,
      unit: u,
    );
  }
}