import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final _firebaseAuth = FirebaseAuth.instance;

  // void test() {
  //   _firebaseAuth.
  // }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    print("Logging in with email: $email and password: $password");
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Stream<User?> get userStream => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;
}
