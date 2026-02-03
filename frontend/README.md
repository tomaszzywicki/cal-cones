# frontend

More or less frontend structure:

```plaintext
lib/
├── main.dart
├── app_widget.dart                       # MaterialApp setup
│
├── core/                                 # Shared infrastructure
│   ├── database/
│   │   ├── local_database_service.dart   # SQLite setup
│   │   └── tables.dart                   # Table schemas
│   ├── network/
│   │   ├── api_client.dart               # HTTP client (dio)
│   │   └── interceptors.dart             # JWT token injection
│   ├── services/
│   │   ├── connectivity_service.dart     # Online/offline detection
│   │   ├── sync_service.dart             # Coordinator for all sync
│   │   └── nutrition_calculator_service.dart  #  Macro calculations
│   └── utils/
│       ├── date_utils.dart
│       └── validators.dart
│
├── shared/                               # Shared domain entities
│   ├── entities/
│   │   └── unit_entity.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       └── error_widget.dart
│
├── features/
│   ├── auth/                             # Authentication
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── firebase_auth_service.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── landing_page.dart
│   │           ├── login_page.dart
│   │           ├── signup_page.dart
│   │           ├── reset_password_page.dart
│   │           └── onboarding_page.dart
│   │
│   ├── user/                             # User profile
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── user_entity.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── user_repository.dart
│   │   │   ├── services/
│   │   │   │   └── user_api_service.dart
│   │   │   └── sync/
│   │   │       └── user_synchronizer.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── profile_page.dart
│   │           ├── edit_profile_page.dart
│   │           └── settings_page.dart
│   │
│   ├── goals/                            # Nutrition goals
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── goal_entity.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── goal_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── goal_repository.dart
│   │   │   ├── services/
│   │   │   │   └── goal_api_service.dart
│   │   │   └── sync/
│   │   │       └── goal_synchronizer.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── goal_setup_page.dart
│   │           ├── goal_details_page.dart
│   │           └── widgets/
│   │               ├── current_goal_progress_card.dart
│   │               └── past_goals_list.dart
│   │
│   ├── meals/                            # Meal logging
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       ├── meal_entity.dart
│   │   │       └── meal_product_entity.dart
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   │   └── meal_repository.dart
│   │   │   ├── services/
│   │   │   │   └── meal_api_service.dart
│   │   │   └── sync/
│   │   │       └── meal_synchronizer.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── meal_log_page.dart
│   │           ├── meal_page.dart
│   │           └── widgets/
│   │               └── meal_card.dart
│   │
│   ├── products/                         # Product database
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── product_entity.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── product_repository.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── product_selection_page.dart
│   │           └── add_product_page.dart
│   │
│   ├── weight/                           # Weight tracking
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── weight_log_entity.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── weight_log_repository.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── weight_log_page.dart
│   │
│   └── home/                             # Dashboard (main screen)
│       └── presentation/
│           ├── pages/
│           │   └── home_page.dart
│           └── widgets/
│               ├── daily_macro_target_widget.dart   # ✅ Z DietAssModule
│               ├── macro_target_glance.dart
│               └── recent_meals_list.dart
│
└── routes/
    └── app_router.dart                   # Navigation (go_router)
```
