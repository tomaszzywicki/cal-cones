import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get userStream => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<String?> getIdToken() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return currentUser.getIdToken();
  }
}
