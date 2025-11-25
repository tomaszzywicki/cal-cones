import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/home/presentation/screens/home_screen.dart';
import 'package:frontend/features/meal_log/presentation/screens/meal_log_screen.dart';
import 'package:frontend/features/other/presentation/screens/other_screen.dart';
import 'package:frontend/features/temp/presentation/screens/user_info.dart';
import 'package:frontend/features/user/presentation/screens/onboarding.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = [HomeScreen(), MealLogScreen(), DashboardScreen(), OtherScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Meal Log'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Other'),
        ],
      ),
    );
  }
}
