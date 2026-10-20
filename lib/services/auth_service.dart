import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  //* Auth State changes =====================================================
  Stream<User?> get authChanges => _auth.authStateChanges();

  //^ Login ==================================================================
  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  //! Logout =================================================================
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sentResetLink(String mailId) async {
    _auth.sendPasswordResetEmail(email: mailId);
  }
}
