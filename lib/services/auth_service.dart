import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    // Makni try-catch odavde, obradićemo ga u UI-u
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // Koristimo tvoj model za kreiranje mape
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          'id': firebaseUser.uid,
          'name': firebaseUser.displayName ?? 'Korisnik',
          'email': firebaseUser.email ?? '',
          'household_id': '',
          'password_hash': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}