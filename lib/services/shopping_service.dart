import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_apps/services/unit_category_service.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../models/shoppingItem.dart';
import '../models/unit.dart';

class ShoppingService {
  final _db = FirebaseFirestore.instance;
  final _masterDataService = MasterDataService();

  // DODAVANJE NA LISTU
  Future<void> addToShoppingList({
    required String householdId,
    required Product product,
    required double quantity,
  }) async {
    await _db.collection('shopping_items').add({
      'household_id': householdId,
      'product': product.toMap(), // Spremamo cijeli product unutra (denormalizacija)
      'quantity': quantity,
      'is_bought': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // KLJUČNI MOMENAT: Kupovina je završena
  // Ova funkcija treba da uradi 3 stvari odjednom:
  Future<void> completePurchase(ShoppingItem item, String householdId, double price) async {
    WriteBatch batch = _db.batch();

    // 1. Oznaci kao kupljeno (ili obriši sa liste)
    batch.delete(_db.collection('shopping_items').doc(item.id));

    // 2. Dodaj u Inventory (da se prati stanje u kući)
    DocumentReference invRef = _db.collection('inventory').doc();
    batch.set(invRef, {
      'household_id': householdId,
      'product': item.product.toMap(),
      'current_quantity': item.quantity,
      'last_updated': FieldValue.serverTimestamp(),
    });

    // 3. Dodaj u Purchase History (za statistiku cijena)
    DocumentReference historyRef = _db.collection('purchase_history').doc();
    batch.set(historyRef, {
      'household_id': householdId,
      'product': item.product.toMap(),
      'price': price,
      'date': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> quickAddToList({
    required String householdId,
    required String productName,
    required double quantity,
    required String unit,
    required String category
  }) async {

    String nameLower = productName.trim().toLowerCase();

    var productQuery = await _db
    .collection('products')
    .where('name', isEqualTo: productName.trim())
    .limit(1)
    .get();

    String productId;
    Category cat;
    Unit u;

    if(productQuery.docs.isNotEmpty) {
      productId = productQuery.docs.first.id;
      var data = productQuery.docs.first.data();

      cat = await _masterDataService.getOrCreateCategory(category);
      u = await _masterDataService.getOrCreateUnit(unit);
    } else {
      cat = await _masterDataService.getOrCreateCategory(category);
      u = await _masterDataService.getOrCreateUnit(unit);

      DocumentReference productRef = _db.collection('products').doc();
      productId = productRef.id;

      Product newProduct = Product(id: productId, name: productName.trim(), category: cat, unit: u );
      await productRef.set(newProduct.toMap());
    }

    await _db
        .collection('households')
        .doc(householdId)
        .collection('shopping_lists')
        .doc('main_list') // Za sada koristimo jednu fiksnu listu
        .collection('items')
        .add({
      'product_id': productId,
      'product_name': productName, // Denormalizacija radi bržeg učitavanja
      'quantity': quantity,
      'category_name': cat.name,
      'unit_name': u.name,
      'is_bought': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}