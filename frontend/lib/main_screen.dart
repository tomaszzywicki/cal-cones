import 'package:flutter/material.dart';
import 'package:frontend/features/temp/presentation/screens/user_info.dart';
import 'package:frontend/features/user/presentation/screens/user_setup.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    // return UserSetup();
    return UserInfo();
  }
}
