import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/unit.dart';

class MasterDataService {
  final _db = FirebaseFirestore.instance;

  // --- KATEGORIJE ---

  // Dohvati sve kategorije za Dropdown (Stream tako da se odmah osvježi)
  Stream<List<Category>> getCategories() {
    return _db.collection('categories').orderBy('name').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Category.fromMap(doc.data(), doc.id)).toList());
  }

  // Provjeri postoji li kategorija po imenu, ako ne, kreiraj je
  Future<Category> getOrCreateCategory(String name) async {
    final normalizedName = name.trim();

    // Tražimo postoji li već kategorija s tim imenom (case-insensitive bi bilo idealno, ali Firestore je striktan)
    final query = await _db
        .collection('categories')
        .where('name', isEqualTo: normalizedName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // Postoji, vrati tu
      return Category.fromMap(query.docs.first.data(), query.docs.first.id);
    } else {
      // Ne postoji, kreiraj novu
      final newDoc = _db.collection('categories').doc();
      final newCat = Category(id: newDoc.id, name: normalizedName);
      await newDoc.set(newCat.toMap());
      return newCat;
    }
  }

  // --- JEDINICE ---

  // Dohvati sve jedinice za Dropdown
  Stream<List<Unit>> getUnits() {
    return _db.collection('units').orderBy('name').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Unit.fromMap(doc.data(), doc.id)).toList());
  }

  // Provjeri postoji li jedinica, ako ne, kreiraj je
  Future<Unit> getOrCreateUnit(String name) async {
    final normalizedName = name.trim().toLowerCase(); // npr. "kg", "kom"

    final query = await _db
        .collection('units')
        .where('name', isEqualTo: normalizedName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Unit.fromMap(query.docs.first.data(), query.docs.first.id);
    } else {
      final newDoc = _db.collection('units').doc();
      final newUnit = Unit(id: newDoc.id, name: normalizedName);
      await newDoc.set(newUnit.toMap());
      return newUnit;
    }
  }
}