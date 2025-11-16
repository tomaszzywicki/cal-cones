import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/signup_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to CalCones App"),
            Placeholder(
              color: Color(0xFF455A64),
              fallbackWidth: 300.0,
              fallbackHeight: 300.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => SignupScreen()));
              },
              child: Text("Get started"),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text("Already have an account?"),
            //     TextButton(
            //       onPressed: () {
            //         Navigator.of(context).push(
            //           MaterialPageRoute(builder: (context) => LoginScreen()),
            //         );
            //       },
            //       child: Text("Sign in"),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
