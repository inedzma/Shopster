import 'package:mobile_apps/models/product.dart';

class InventoryItem{
  final String id;
  final Product product;
  final double currentQuantity;
  final DateTime lastUpdated;

  InventoryItem({required this.id, required this.product, required this.currentQuantity, required this.lastUpdated});

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'product_id': product.id,
      'current_quantity': currentQuantity,
      'last_updated': lastUpdated.toIso8601String()
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map, Product product){
    return InventoryItem(
        id: map['id'], 
        product: product, 
        currentQuantity: map['current_quantity'], 
        lastUpdated: DateTime.parse(map['last_updated'])
    );
  }
}