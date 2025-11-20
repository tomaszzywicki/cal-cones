import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/user/data/user_onboarding_model.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/1_onboarding_name.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/2_onboarding_birthday.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/3_onboarding_sex.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/4_onboarding_height.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/5_onboarding_weight.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/6_onboarding_activity.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/7_onboarding_diet.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/8_onboarding_goal_type.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/9_onboarding_goal_data.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/goal_setup.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/onboarding_summary.dart';
import 'package:frontend/main_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:provider/provider.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController(initialPage: 1);
  bool onFirstPage = true;
  bool onLastPage = false;

  // Onboarding data
  String? _name;
  DateTime? _birthday;
  String? _sex;
  int? _height;
  String? _activityLevel;
  String? _dietType;
  Map<String, int>? _macroSplit;
  String? _goalType; // lose / maintaint / gain  ale nie wiem czy to zapisywać wgl
  DateTime? _startDate;
  DateTime? _targetDate;
  double? _startWeight;
  double? _targetWeight;
  double? _tempo;

  void _goToPreviousPage() {
    _pageController.previousPage(duration: Duration(microseconds: 200), curve: Curves.easeInOut);
  }

  void _goToNextPage() {
    _pageController.nextPage(duration: Duration(microseconds: 200), curve: Curves.easeInOut);
  }

  void _updateName(String username) {
    setState(() => _name = username);
    _goToNextPage();
  }

  void _updateBirthday(int day, int month, int year) {
    setState(() => _birthday = DateTime(year, month, day));
    _goToNextPage();
  }

  void _updateSex(String sex) {
    setState(() => _sex = sex);
    _goToNextPage();
  }

  void _updateHeight(int height) {
    setState(() => _height = height);
    _goToNextPage();
  }

  void _updateWeight(double weight) {
    setState(() => _startWeight = weight);
    _goToNextPage();
  }

  void _updateActivityLevel(String activityLevel) {
    setState(() => _activityLevel = activityLevel);
    _goToNextPage();
  }

  void _updateDietAndMacro(String dietType, Map<String, int> macroSplit) {
    setState(() {
      _dietType = dietType;
      _macroSplit = macroSplit;
    });
    _goToNextPage();
  }

  void _updateGoalType(String goalType) {
    setState(() => _goalType = goalType);
    _goToNextPage();
  }

  void _updateGoalData(DateTime startDate, DateTime targetDate, double targetWeight, double tempo) {
    setState(() {
      _startDate = startDate;
      _targetDate = targetDate;
      _targetWeight = targetWeight;
      _tempo = tempo;
    });
    _goToNextPage();
  }

  void _saveOnboardingInfo() {
    final currentUserService = Provider.of<CurrentUserService>(context, listen: false);
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
      startDate: DateTime(2025, 10, 10),
      targetDate: DateTime(2025, 11, 10),
      startWeight: _startWeight!,
      targetWeight: 80,
      tempo: 0.5,
    );
    AppLogger.debug("saving onbording info. ${userOnboardingModel.toJson()}");
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      OnboardingName(setName: (name) => _updateName(name)),
      OnboardingBirthday(setBirthday: (day, month, year) => _updateBirthday(day, month, year)),
      OnboardingSex(setName: (sex) => _updateSex(sex)),
      OnboardingHeight(setHeight: (height) => _updateHeight(height)),
      OnboardingWeight(setWeight: (weight) => _updateWeight(weight)),
      OnboardingActivity(setActivityLevel: (activityLevel) => _updateActivityLevel(activityLevel)),
      OnboardingDiet(setDietAndMacro: (dietType, macroSplit) => _updateDietAndMacro(dietType, macroSplit)),
      OnboardingGoalType(setGoalType: (type) => _updateGoalType(type)),
      OnbboardingGoalData(
        setGoalData: (startDate, targetDate, targetWeight, tempo) =>
            _updateGoalData(startDate, targetDate, targetWeight, tempo),
      ),
      OnboardingSummary(),
    ];
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50),
          SmoothPageIndicator(
            controller: _pageController,
            count: pages.length,
            effect: WormEffect(
              dotWidth: 30,
              dotHeight: 4,
              activeDotColor: Colors.grey[800]!,
              dotColor: Colors.grey[300]!,
              spacing: 6,
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  onFirstPage = (index == 0);
                  onLastPage = (index == pages.length - 1);
                });
              },
              children: pages,
            ),
          ),

          Container(
            alignment: Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onFirstPage
                      ? null
                      : () {
                          _goToPreviousPage();
                        },
                  child: Text("Back"),
                ),

                // progress indicator (dots on the screen)
                ElevatedButton(
                  onPressed: onLastPage
                      ? () {
                          _saveOnboardingInfo();
                        }
                      : () {
                          _goToNextPage();
                        },
                  child: onLastPage ? Text("Done") : Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
