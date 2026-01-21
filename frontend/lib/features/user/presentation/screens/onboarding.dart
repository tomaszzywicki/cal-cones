import 'package:flutter/material.dart';
import 'package:frontend/core/network/connectivity_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/user/data/user_onboarding_model.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/9_onboarding_final.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/1_onboarding_name.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/2_onboarding_birthday.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/3_onboarding_sex.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/4_onboarding_height.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/5_onboarding_weight.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/6_onboarding_activity.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/7_onboarding_diet.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/8_onboarding_goal_data.dart';
import 'package:frontend/features/user/services/user_service.dart';
import 'package:frontend/main_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:frontend/core/logger/app_logger.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _Onboarding();
}

class _Onboarding extends State<Onboarding> {
  final PageController _pageController = PageController(initialPage: 0);
  bool onFirstPage = true;
  bool onLastPage = false;

  // Change page animation
  final Duration _animDuration = const Duration(milliseconds: 300);
  final Curve _animCurve = Curves.easeInOut;

  // Onboarding data
  String? _name;
  DateTime? _birthday;
  String? _sex;
  int? _height;
  String? _activityLevel;
  String? _dietType;
  Map<String, int>? _macroSplit;
  DateTime? _startDate;
  DateTime? _targetDate;
  double? _startWeight;
  double? _targetWeight;
  double? _tempo;

  void _updateName(String username) {
    setState(() => _name = username);
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
  }

  void _updateBirthday(int day, int month, int year) {
    setState(() => _birthday = DateTime(year, month, day));
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
  }

  void _updateSex(String sex) {
    setState(() => _sex = sex);
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
  }

  void _updateHeight(int height) {
    setState(() => _height = height);
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
  }

  void _updateWeight(double weight) {
    setState(() => _startWeight = weight);
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
    AppLogger.debug("setting weight: $weight");
  }

  void _updateActivityLevel(String activityLevel) {
    setState(() => _activityLevel = activityLevel);
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
  }

  void _updateDietAndMacro(String dietType, Map<String, int> macroSplit) {
    setState(() {
      _dietType = dietType;
      _macroSplit = macroSplit;
    });
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
  }

  void _updateGoalData(DateTime startDate, DateTime targetDate, double targetWeight, double tempo) {
    setState(() {
      _startDate = startDate;
      _targetDate = targetDate;
      _targetWeight = targetWeight;
      _tempo = tempo;
    });
    _pageController.nextPage(duration: _animDuration, curve: _animCurve);
  }

  Future<void> _saveOnboardingInfo() async {
    final connectivityService = context.read<ConnectivityService>();
    final currentUserService = context.read<CurrentUserService>();
    final userService = context.read<UserService>();
    bool isConnected = connectivityService.isConnected;

    double weightDifference = _startWeight! - _targetWeight!;
    bool isMaintenanceMode = weightDifference.abs() < 0.1;
    if (isMaintenanceMode) {
      _tempo = 0.0;
    }

    final userOnboardingModel = UserOnboardingModel(
      id: currentUserService.currentUser!.id!,
      uid: currentUserService.currentUser!.uid,
      username: _name!,
      birthday: _birthday!,
      sex: _sex!,
      height: _height!,
      dietType: _dietType!,
      macroSplit: _macroSplit!,
      activityLevel: _activityLevel!,
      startDate: _startDate!,
      targetDate: _targetDate!,
      startWeight: _startWeight!,
      targetWeight: _targetWeight!,
      tempo: _tempo!,
    );

    AppLogger.debug("saving onbording info. ${userOnboardingModel.toJson()}");
    if (!isConnected) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check internet connection and try again')));
    } else {
      try {
        await userService.saveOnboardingInfo(userOnboardingModel);
        AppLogger.info("Onboarding info saved successfully.");
        Navigator.of(
          context,
        ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainScreen()), (route) => false);
      } catch (e) {
        AppLogger.error("Error saving onboarding info: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving data. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // 1.
      OnboardingName(setName: (name) => _updateName(name), initialName: _name),
      // 2.
      OnboardingBirthday(
        setBirthday: (day, month, year) => _updateBirthday(day, month, year),
        initialDay: _birthday?.day,
        initialMonth: _birthday?.month,
        initialYear: _birthday?.year,
      ),
      // 3.
      OnboardingSex(setSex: (sex) => _updateSex(sex), initialSex: _sex),
      // 4.
      OnboardingHeight(setHeight: (height) => _updateHeight(height), initialHeight: _height),
      // 5.
      OnboardingWeight(setWeight: (weight) => _updateWeight(weight), initialWeight: _startWeight, sex: _sex),
      // 6.
      OnboardingActivity(
        setActivityLevel: (activityLevel) => _updateActivityLevel(activityLevel),
        initialActivityLevel: _activityLevel,
      ),
      // 7.
      OnboardingDiet(
        setDietAndMacro: (dietType, macroSplit) => _updateDietAndMacro(dietType, macroSplit),
        initialDietType: _dietType,
        initialMacroSplit: _macroSplit,
      ),

      // 8.
      OnbboardingGoalData(
        setGoalData: (startDate, targetDate, targetWeight, tempo) =>
            _updateGoalData(startDate, targetDate, targetWeight, tempo),
        initialStartDate: _startDate,
        initialTargetDate: _targetDate,
        initialTargetWeight: _targetWeight,
        initialTempo: _tempo,
        currentWeight: _startWeight,
      ),
      // 9.
      OnboardingFinal(
        finishOnboarding: () => _saveOnboardingInfo(),
        name: _name,
        birthday: _birthday,
        sex: _sex,
        height: _height,
        startWeight: _startWeight,
        targetWeight: _targetWeight,
        activityLevel: _activityLevel,
        dietType: _dietType,
        targetDate: _targetDate,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header: Back Button + Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
              child: Column(
                children: [
                  // Page Indicator (Top)
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: WormEffect(
                      dotWidth: 30,
                      dotHeight: 4,
                      activeDotColor: const Color(0xFF0C1C24),
                      dotColor: Colors.grey[300]!,
                      spacing: 6,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Back Button (Below, Left-aligned)
                  SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: !onFirstPage
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black87),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _pageController.previousPage(duration: _animDuration, curve: _animCurve);
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // DISABLED SWIPING
                onPageChanged: (index) {
                  setState(() {
                    onFirstPage = (index == 0);
                    onLastPage = (index == pages.length - 1);
                  });
                },
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
