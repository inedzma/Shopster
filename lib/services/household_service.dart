import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/household.dart';

class HouseholdService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createHousehold(String name, String inviteCode) async {

    DocumentReference docRef = _db.collection('households').doc();
    String autoId = docRef.id;

    Household newHousehold = Household(
        id: autoId,
        name: name,
        inviteCode: inviteCode
    );

    await docRef.set(newHousehold.toMap());
  }

  Future<Household?> findByInvitecode(String code) async {
    var query = await _db
        .collection('households')
        .where('invite_code', isEqualTo: code)
        .get();

    if (query.docs.isNotEmpty) {
      return Household.fromMap(query.docs.first.data());
    }
    return null;
  }
}