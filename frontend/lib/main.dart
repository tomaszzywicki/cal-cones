import 'package:flutter/material.dart';
import 'package:frontend/app_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/core/network/connectivity_service.dart';
import 'package:frontend/core/sync/sync_queue_repository.dart';
import 'package:frontend/core/sync/sync_service.dart';
import 'package:frontend/features/ai/services/ai_api_service.dart';
import 'package:frontend/features/ai/services/ai_service.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/auth/services/firebase_auth_service.dart';
import 'package:frontend/features/meal/services/day_macro_provider.dart';
import 'package:frontend/features/meal/services/meal_api_service.dart';
import 'package:frontend/features/meal/services/meal_repository.dart';
import 'package:frontend/features/meal/services/meal_service.dart';
import 'package:frontend/features/meal/services/meal_sync_service.dart';
import 'package:frontend/features/product/services/product_api_service.dart';
import 'package:frontend/features/product/services/product_repository.dart';
import 'package:frontend/features/product/services/product_service.dart';
import 'package:frontend/features/product/services/product_sync_service.dart';
import 'package:frontend/features/user/services/user_api_service.dart';
import 'package:frontend/features/user/services/user_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('[App] Starting CalCones app...');

  await Firebase.initializeApp();
  AppLogger.info('[App] Firebase initialized');

  // core
  final localDatabaseService = LocalDatabaseService();
  final connectivityService = ConnectivityService();
  await connectivityService.initConnectivity();
  final syncQueueRepository = SyncQueueRepository(localDatabaseService);

  // auth
  final firebaseAuthService = FirebaseAuthService();
  final authApiService = AuthApiService(firebaseAuthService);
  final currentUserService = CurrentUserService();

  // user
  final userApiService = UserApiService(firebaseAuthService);
  final userService = UserService(userApiService, currentUserService);
  // product
  final productRepository = ProductRepository(localDatabaseService);
  final productApiService = ProductApiService(firebaseAuthService);
  final productSyncService = ProductSyncService(
    repository: productRepository,
    apiService: productApiService,
    syncQueueRepository: syncQueueRepository,
  );
  final productService = ProductService(
    productRepository,
    productSyncService,
    currentUserService,
    connectivityService,
  );

  // meal
  final mealRepository = MealRepository(localDatabaseService);
  final mealApiService = MealApiService(firebaseAuthService);
  final mealSyncService = MealSyncService(
    repository: mealRepository,
    apiService: mealApiService,
    syncQueueRepository: syncQueueRepository,
  );
  final mealService = MealService(mealRepository, mealSyncService, currentUserService, connectivityService);
  final dayMacroProvider = DayMacroProvider();

  // ai
  final aiApiService = AIApiService(firebaseAuthService);
  final aiService = AIService(aiApiService: aiApiService);

  // sync
  final syncService = SyncService(
    connectivityService: connectivityService,
    productSyncService: productSyncService,
    mealSyncService: mealSyncService,
  );
  syncService.init();

  // auth znów
  final authService = AuthService(firebaseAuthService, authApiService, currentUserService, syncService);

  await currentUserService.initialize();

  if (currentUserService.isLoggedIn && connectivityService.isConnected) {
    await syncService.syncFromServer(currentUserService.getUserId());
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalDatabaseService>.value(value: localDatabaseService),
        Provider<FirebaseAuthService>.value(value: firebaseAuthService),
        Provider<AuthService>.value(value: authService),
        Provider<UserService>.value(value: userService),
        Provider<ProductService>.value(value: productService),
        Provider<MealService>.value(value: mealService),
        Provider<AIService>.value(value: aiService),
        ChangeNotifierProvider<CurrentUserService>.value(value: currentUserService),
        ChangeNotifierProvider<ConnectivityService>.value(value: connectivityService),
        ChangeNotifierProvider<DayMacroProvider>.value(value: dayMacroProvider),
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
