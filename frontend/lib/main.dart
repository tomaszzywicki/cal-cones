import 'package:flutter/material.dart';
import 'package:frontend/app_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('[App] Starting CalCones app...');

  await Firebase.initializeApp();
  AppLogger.info('[App] Firebase initialized');

  final firebaseAuthService = FirebaseAuthService();
  final authApiService = AuthApiService(firebaseAuthService);
  final currentUserService = CurrentUserService();
  final authService = AuthService(firebaseAuthService, authApiService, currentUserService);

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseAuthService>.value(value: firebaseAuthService),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<CurrentUserService>.value(value: currentUserService),
      ],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppWidget();
  }
}
