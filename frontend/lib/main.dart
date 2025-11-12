import 'package:flutter/material.dart';
import 'package:frontend/app_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firebaseAuthService = FirebaseAuthService();
  final authApiService = AuthApiService(firebaseAuthService);
  final authService = AuthService(firebaseAuthService, authApiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseAuthService>.value(value: firebaseAuthService),
        Provider<AuthService>.value(value: authService),
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
