import 'dart:convert';

import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/data/user_auth_model.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/features/user/data/user_model.dart';

class AuthService {
  static const String _tag = 'AuthService';

  final FirebaseAuthService _firebaseAuthService;
  final AuthApiService _authApiService;
  final CurrentUserService _currentUserService;

  AuthService(this._firebaseAuthService, this._authApiService, this._currentUserService);

  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Login with Firebase
      final userCredential = await _firebaseAuthService.signInWithEmailAndPassword(email, password);

      if (userCredential.user == null) {
        throw AuthException('Sign in failed: user is null');
      }

      // 2. Get user data from backend
      final userAuthData = UserAuthModel(uid: userCredential.user!.uid, email: userCredential.user!.email!);

      final response = await _authApiService.signIn(userAuthData);

      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(jsonDecode(response.body));
        await _currentUserService.setUser(userModel);
        return userModel;
      } else {
        AppLogger.info('[$_tag] Backend user data fetch failed: ${response.statusCode} - ${response.body}');
        throw AuthException('Backend user data fetch failed: ${response.body}');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Unexpected error during sign in: $e');
    }
  }

  Future<UserModel> signUp(String email, String password) async {
    AppLogger.info('[$_tag] Starting signup for email: $email');

    UserCredential? userCredential;
    try {
      // 1. Create Firebase account and get UserCredential containing idToken
      AppLogger.info('[$_tag] Creating firebase account...');
      userCredential = await _firebaseAuthService.signUpWithEmailAndPassword(email, password);

      if (userCredential.user == null) {
        AppLogger.error('[$_tag] Firebase signup failed: user is null');
        throw AuthException('Sign up failed: user is null');
      }

      AppLogger.info('[$_tag] Firebase account created successfully. UID: ${userCredential.user!.uid}');

      // 2. Register user at our backend
      final userAuthData = UserAuthModel(uid: userCredential.user!.uid, email: userCredential.user!.email!);

      final response = await _authApiService.signUp(userAuthData);

      if (response.statusCode == 201) {
        AppLogger.info('[$_tag] User ${userAuthData.email} registered successfully on backend');
        final userModel = UserModel.fromJson(jsonDecode(response.body));
        // 3. Save user to local storage
        _currentUserService.setUser(userModel);
        return userModel;
      } else {
        AppLogger.info('[$_tag] Backend registration failed: ${response.statusCode} - ${response.body}');
        throw AuthException('Backend registration failed ${response.body}');
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error('[$_tag] Firebase auth error: ${e.code}', e);
      await _rollbackFirebaseAccount(userCredential);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('[$_tag] Unexpected signup error', e, stackTrace);
      await _rollbackFirebaseAccount(userCredential);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuthService.signOut();
      await _currentUserService.clearUser();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  Future<void> _rollbackFirebaseAccount(UserCredential? userCredential) async {
    if (userCredential?.user != null) {
      try {
        AppLogger.info('🔄 Rolling back Firebase account creation...');

        // Delete Firebase account
        await _firebaseAuthService.deleteFirebaseAccount(userCredential!);

        AppLogger.info('✅ Firebase account rollback successful');
      } catch (rollbackError) {
        AppLogger.error('❌ Firebase rollback failed: $rollbackError');
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
