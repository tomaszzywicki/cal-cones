import 'package:flutter/material.dart';
import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context, listen: true);
    return MaterialApp(
      home: StreamBuilder(
        stream: authService.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting) {
            // TODO
            // throw UnimplementedError("waiting");
            return Center(child: CircularProgressIndicator());
            // return
          }

          if (snapshot.hasData) {
            return MainScreen();
          } else {
            // return Center(child: Text("dupa nie użytkownik"));
            return LoginScreen();
          }
        },
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context, listen: true);
    final user = authService.currentUser;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logged in as ${user?.email}"),
            ElevatedButton(
              onPressed: () async {
                authService.signOut();
              },
              child: Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}
