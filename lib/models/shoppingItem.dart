import 'package:mobile_apps/models/product.dart';

class ShoppingItem{
  final String id;
  final Product product;
  final double quantity;
  final bool? isBought;

  ShoppingItem({required this.id, required this.product, required this.quantity, required this.isBought});

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'product_id': product.id,
      'quantity': quantity,
      'is_bought': isBought,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map, Product product, String docId){
    return ShoppingItem(
        id: docId,
        product: product,
        quantity: (map['quantity'] as num).toDouble(),
        isBought: map['is_bought'] ?? false,
    );
  }
}