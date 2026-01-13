import 'package:flutter/material.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/home/presentation/screens/home_screen.dart';
import 'package:frontend/features/meal_log/presentation/screens/meal_log_screen.dart';
import 'package:frontend/features/other/presentation/screens/other_screen.dart';
import 'package:frontend/show_menu_bottom_sheet.dart';

final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

// 1. Key to access HomeScreen state
final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 2. Assign Key to HomeScreen
  final List<Widget> _screens = [
    HomeScreen(key: homeScreenKey),
    MealLogScreen(),
    DashboardScreen(),
    OtherScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[50],
        currentIndex: _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex,
        onTap: (index) => _onBottomNavTap(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 26, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: 26, color: Colors.black),
            label: 'Meal Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_sharp, size: 40, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 26, color: Colors.black),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, size: 26, color: Colors.black),
            label: 'Other',
          ),
        ],
      ),
    );
  }

  void _onBottomNavTap(int index) {
    if (index == 2) {
      ShowMenuBottomSheet.show(context);
      return;
    }

    int pageIndex = index >= 2 ? index - 1 : index;
    setState(() => _currentIndex = pageIndex);

    // 3. Auto-Refresh Logic
    if (pageIndex == 0) {
      // Refresh Home Screen Macros
      homeScreenKey.currentState?.loadTodayMacros();
    }
  }

  void navigateToMealLog() {
    setState(() {
      _currentIndex = 1;
    });
  }
}
