import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/landing_page.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:frontend/features/user/presentation/screens/onboarding.dart';
import 'package:frontend/main_screen.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalCones',
      // themeMode: ThemeMode.system,
      home: Consumer2<FirebaseAuthService, CurrentUserService>(
        builder: (context, authService, currentUserService, _) {
          return StreamBuilder(
            stream: authService.userStream,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // Not logged in → Landing Page
              if (!snapshot.hasData || snapshot.data == null) {
                return const LandingPage();
              }

              // Logged in → sprawdź setupCompleted
              // Czy CurrentUserService ma dane użytkownika
              if (!currentUserService.isInitialized) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final user = currentUserService.currentUser;

              // Nie ma danych użytkownika → Landing Page
              if (user == null) {
                return const LandingPage();
              }

              // Setup not completed → Onboarding
              if (!user.setupCompleted) {
                // return const MainScreen();
                return Onboarding();
              } else {
                // Setup completed → Main Screen
                return const MainScreen();
              }
            },
          );
        },
      ),
    );
  }
}
