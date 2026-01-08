// FILE: lib/services/auth_service.dart
// OPIS: Upravlja prijavom i odjavom vlasnika (Firebase Auth).

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream koji prati je li korisnik ulogiran
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login funkcija
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Nema greške, uspjeh!
    } on FirebaseAuthException catch (e) {
      return e.message; // Vrati poruku greške (npr. "Wrong password")
    } catch (e) {
      return "An unknown error occurred.";
    }
  }

  // Logout funkcija
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
