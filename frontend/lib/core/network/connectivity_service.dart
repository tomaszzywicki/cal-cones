import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend/core/logger/app_logger.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  VoidCallback? onConnectivityRestored;

  Future<void> initConnectivity() async {
    try {
      await checkConnectivity();

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    } catch (e) {
      AppLogger.error('Error initializing connectivity: $e');
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final bool wasConnected = _isConnected;
    if (result == ConnectivityResult.none) {
      _isConnected = false;
    } else {
      _isConnected = await _hasInternetConnection();
    }

    if (!wasConnected && _isConnected) {
      AppLogger.debug('Connection restored');
      onConnectivityRestored?.call();
    }

    if (wasConnected != _isConnected) {
      notifyListeners();
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final uri = Uri.parse('https://www.google.com/generate_204');
      final httpClient = HttpClient();

      final request = await httpClient.getUrl(uri).timeout(const Duration(seconds: 5));

      final response = await request.close().timeout(const Duration(seconds: 5));

      httpClient.close();

      if (response.statusCode == 204) {
        AppLogger.debug('Internet connection verified via HTTP');
        return true;
      }

      AppLogger.warning('Unexpected HTTP status: ${response.statusCode}');
      return false;
    } on SocketException catch (e) {
      AppLogger.warning('Socket exception: $e');
      return false;
    } on TimeoutException catch (e) {
      AppLogger.warning('Timeout: $e');
      return false;
    } catch (e) {
      AppLogger.error('Error checking internet: $e');
      return false;
    }
  }

  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(result);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
