import 'package:flutter/material.dart';
import 'package:frontend/app_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/network/connectivity_service.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:frontend/features/meal/services/meal_api_service.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/product/services/product_repository.dart';
import 'package:frontend/features/product/services/product_service.dart';
import 'package:frontend/features/user/services/user_api_service.dart';
import 'package:frontend/features/user/services/user_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('[App] Starting CalCones app...');

  await Firebase.initializeApp();
  AppLogger.info('[App] Firebase initialized');

  final localDatabaseService = LocalDatabaseService();
  final connectivityService = ConnectivityService()..initConnectivity();
  // auth
  final firebaseAuthService = FirebaseAuthService();
  final authApiService = AuthApiService(firebaseAuthService);
  final currentUserService = CurrentUserService();
  final authService = AuthService(firebaseAuthService, authApiService, currentUserService);
  // user
  final userApiService = UserApiService(firebaseAuthService);
  final userService = UserService(userApiService, currentUserService);
  // product
  final productRepository = ProductRepository(localDatabaseService);
  final productService = ProductService(productRepository);

  // meal
  final mealApiService = MealApiService(firebaseAuthService);
  final mealRepository = MealRepository(localDatabaseService);
  final mealService = MealService(mealApiService, mealRepository, currentUserService);

  await currentUserService.initialize();
  runApp(
    MultiProvider(
      providers: [
        Provider<UserService>.value(value: userService),
        Provider<FirebaseAuthService>.value(value: firebaseAuthService),
        Provider<AuthService>.value(value: authService),
        Provider<ProductService>.value(value: productService),
        Provider<MealService>.value(value: mealService),
        ChangeNotifierProvider<CurrentUserService>.value(value: currentUserService),
        ChangeNotifierProvider<ConnectivityService>.value(value: connectivityService),
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
