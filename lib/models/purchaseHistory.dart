class PurchaseHistory {
  final int id;
  final int productId;
  final double quantity;
  final double price;
  final DateTime date;

  PurchaseHistory({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'date': date.toIso8601String(), // Spremanje datuma kao String
    };
  }

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'],
      productId: map['product_id'],
      quantity: map['quantity'].toDouble(),
      price: map['price'].toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}