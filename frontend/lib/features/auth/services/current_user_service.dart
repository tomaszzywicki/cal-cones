import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/user/data/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentUserService extends ChangeNotifier {
  static const String _tag = 'CurrentUserService';
  static const String _userKey = 'current_user';

  UserModel? _currentUser;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _currentUser != null;

  UserModel? get currentUser => _currentUser;

  // Public methods

  Future<void> initialize() async {
    if (_isInitialized) return;

    AppLogger.debug('[$_tag] Initializing CurrentUserService...');
    await _loadUserFromStorage();
    _isInitialized = true;
    AppLogger.info('[$_tag] CurrentUserService initialized. User logged in: $isLoggedIn');
  }

  Future<void> setUser(UserModel user) async {
    AppLogger.info('[$_tag] Setting current user: ${user.email}');
    _currentUser = user;
    await _saveUserToStorage(user);
    notifyListeners();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    if (_currentUser?.id == updatedUser.id) {
      AppLogger.debug('[$_tag] Updating current user data');
      await setUser(updatedUser);
    }
  }

  Future<void> clearUser() async {
    AppLogger.info('[$_tag] Clearing current user');
    _currentUser = null;
    await _removeUserFromStorage();
    notifyListeners();
  }

  // Private methods

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = UserModel.fromMap(userData);
        AppLogger.debug('[$_tag] User loaded from storage: ${_currentUser!.email}');
      } else {
        AppLogger.debug('[$_tag] No user found in storage');
      }
    } catch (e) {
      AppLogger.error('[$_tag] Failed to load user from storage', e);
      await _removeUserFromStorage();
    }
  }

  Future<void> _saveUserToStorage(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMap = jsonEncode(user.toMap());
      await prefs.setString(_userKey, userMap);
      AppLogger.debug('[$_tag] User saved to storage');
    } catch (e) {
      AppLogger.error('[$_tag] Failed to save user to storage', e);
    }
  }

  Future<void> _removeUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(_userKey);
      AppLogger.debug('[$_tag] User removed from storage');
    } catch (e) {
      AppLogger.error('[$_tag] Failed to remove user from storage', e);
    }
  }
}
