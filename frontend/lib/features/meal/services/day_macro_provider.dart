import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/goal/services/daily_target_repository.dart';

class DayMacroProvider extends ChangeNotifier {
  final DailyTargetRepository _dailyTargetRepository;
  final CurrentUserService _currentUserService;
  DayMacroProvider(this._dailyTargetRepository, this._currentUserService);

  Future<void> getTodayKcal() async {}
  Future<void> getTodayCarbs() async {}
  Future<void> getTodayProtein() async {}
  Future<void> getTodayFat() async {}
}
