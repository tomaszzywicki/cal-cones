import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void signIn() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    final authservice = Provider.of<FirebaseAuthService>(
      context,
      listen: false,
    );
    authservice.signInWithEmailAndPassword(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome back"),
              TextFormField(controller: _emailController),
              TextFormField(controller: _passwordController, obscureText: true),
              ElevatedButton(onPressed: signIn, child: Text("Log in")),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(onPressed: () {}, child: Text("Sign up")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
