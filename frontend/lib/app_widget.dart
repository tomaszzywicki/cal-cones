import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/landing_page.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:frontend/main_screen.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalCones',
      // themeMode: ThemeMode.system,
      home: Consumer<FirebaseAuthService>(
        builder: (context, authService, _) {
          return StreamBuilder(
            stream: authService.userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.hasData && snapshot.data != null) {
                return MainScreen();
              } else {
                return LandingPage();
              }
            },
          );
        },
      ),
    );
  }
}
