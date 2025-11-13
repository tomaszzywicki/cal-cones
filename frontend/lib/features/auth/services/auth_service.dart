import 'dart:convert';

import 'package:frontend/features/auth/data/user_auth_model.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/features/user/data/user_model.dart';

class AuthService {
  final FirebaseAuthService _firebaseAuthService;
  final AuthApiService _authApiService;

  AuthService(this._firebaseAuthService, this._authApiService);

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuthService.signInWithEmailAndPassword(email, password);

      if (userCredential.user == null) {
        throw AuthException('Sign in failed: user is null');
      }
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Unexpected error during sign in: $e');
    }
  }

  Future<UserModel> signUp(String email, String password) async {
    UserCredential? userCredential;
    try {
      // 1. Create Firebase account and get UserCredential containing idToken
      userCredential = await _firebaseAuthService.signUpWithEmailAndPassword(email, password);

      if (userCredential.user == null) {
        throw AuthException('Sign up failed: user is null');
      }

      // 2. Register user at our backend
      final userAuthData = UserAuthModel(uid: userCredential.user!.uid, email: userCredential.user!.email!);

      final response = await _authApiService.signUp(userAuthData);

      if (response.statusCode == 409) {
        throw AuthException('User already exists');
      } else if (response.statusCode != 201) {
        // Fail at backend -> rollback
        await _firebaseAuthService.signOut();
        _firebaseAuthService.deleteFirebaseAccount(userCredential);
        throw AuthException('Failed to create user account: ${response.statusCode}. ${response.body}');
      }

      // Everything went well -> return UserModel
      final json = jsonDecode(response.body);
      final userModel = UserModel.fromJson(json);

      return userModel;
    } on FirebaseAuthException catch (e) {
      await _rollbackFirebaseAccount(userCredential);
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      await _rollbackFirebaseAccount(userCredential);

      if (e is AuthException) rethrow;
      throw AuthException('Unexpected error during sign up: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuthService.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  Future<void> _rollbackFirebaseAccount(UserCredential? userCredential) async {
    if (userCredential?.user != null) {
      try {
        print('🔄 Rolling back Firebase account creation...');

        // Delete Firebase account
        await _firebaseAuthService.deleteFirebaseAccount(userCredential!);

        print('✅ Firebase account rollback successful');
      } catch (rollbackError) {
        print('❌ Firebase rollback failed: $rollbackError');
      }
    }
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email');
      case 'wrong-password':
        return AuthException('Incorrect password');
      case 'invalid-email':
        return AuthException('Invalid email address');
      case 'user-disabled':
        return AuthException('This account has been disabled');
      case 'too-many-requests':
        return AuthException('Too many attempts. Please try again later');
      case 'email-already-in-use':
        return AuthException('Email already in use');
      case 'weak-password':
        return AuthException('Password is too weak');
      default:
        return AuthException('Authentication error: ${e.message}');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
