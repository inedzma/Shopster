import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/household.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(User user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<User?> getUserWithHousehold(String userId) async {

    DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();

    if (!userDoc.exists) return null;

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    String householdId = userData['household_id'];


    DocumentSnapshot householdDoc = await _db.collection('households').doc(householdId).get();

    if (householdDoc.exists) {
      Household household = Household.fromMap(
          householdDoc.data() as Map<String, dynamic>
      );

      return User.fromMap(userData, household);
    }

    return null;
  }
}