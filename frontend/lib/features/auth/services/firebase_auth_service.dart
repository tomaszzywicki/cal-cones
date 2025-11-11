import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  // void test() {
  //   _firebaseAuth.signout
  // }

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

  Stream<User?> get userStream => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
}
