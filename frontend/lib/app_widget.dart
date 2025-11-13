import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                return LoginScreen();
              }
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    final currentUserService = Provider.of<CurrentUserService>(context, listen: false);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User Info", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text("Email: ${currentUserService.currentUser?.email}", style: TextStyle(fontSize: 18)),
              Text("UID: ${currentUserService.currentUser?.uid}"),
              Text("Display Name: ${currentUserService.currentUser?.username ?? 'N/A'}"),
              Text("Created At: ${currentUserService.currentUser?.createdAt}"),
              Text("Last Modified At: ${currentUserService.currentUser?.lastModifiedAt}"),
              Text("Setup Completed: ${currentUserService.currentUser?.setupCompleted}"),
              ElevatedButton(
                onPressed: () async {
                  authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                child: Text("Log out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
