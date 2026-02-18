import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_apps/models/product.dart';
import 'package:mobile_apps/models/category.dart';
import 'package:mobile_apps/models/unit.dart';

class ProductsService{
  final _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {

    return _db.collection('categories').snapshots().asyncMap((catSnap) async {

      Map<String, Category> categoriesMap = {
        for(var doc in catSnap.docs) doc.id: Category.fromMap(doc.data(), doc.id)
      };

      var unitSnap = await _db.collection('units').get();
      Map<String, Unit> unitsMap = {
        for(var doc in unitSnap.docs) doc.id: Unit.fromMap(doc.data(),doc.id)
      };

      var prodSnap = await _db.collection('products').orderBy('name').get();

      return prodSnap.docs.map((doc) {
        var data = doc.data();

        Category cat = categoriesMap[data['category_id']] ?? Category(name: 'Nepoznato', id: '?');
        Unit u = unitsMap[data['unit_id']] ?? Unit(id: '?', name: 'kom');

        return Product.fromMap(data, cat, u);
      }).toList();
    });
  }
}