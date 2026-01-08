import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingActivity extends StatefulWidget {
  final Function(String name) setActivityLevel;
  final String? initialActivityLevel;

  const OnboardingActivity({super.key, required this.setActivityLevel, this.initialActivityLevel});

  @override
  State<OnboardingActivity> createState() => _OnboardingActivityState();
}

class _OnboardingActivityState extends State<OnboardingActivity> {
  String? _selectedActivityLevel;
  bool _isFirstSelected = false;
  bool _isSecondSelected = false;
  bool _isThirdSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialActivityLevel != null) {
      _selectedActivityLevel = widget.initialActivityLevel;
      _isFirstSelected = _selectedActivityLevel == 'sedentary';
      _isSecondSelected = _selectedActivityLevel == 'moderately_active';
      _isThirdSelected = _selectedActivityLevel == 'very_active';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(height: 100),
              Text('What is your activity level?', style: TextTheme.of(context).headlineMedium),
              SizedBox(height: 50),
              _activityContainer('Mostly Sedentary', 'Little or no exercise', () {
                setState(() {
                  _isFirstSelected = true;
                  _isSecondSelected = false;
                  _isThirdSelected = false;
                  _selectedActivityLevel = 'sedentary';
                });
              }, _isFirstSelected ? Colors.grey[400] : Colors.white),
              SizedBox(height: 10),
              _activityContainer('Moderately Active', '2 to 3 workouts a week', () {
                setState(() {
                  _isFirstSelected = false;
                  _isSecondSelected = true;
                  _isThirdSelected = false;
                  _selectedActivityLevel = 'moderately_active';
                });
              }, _isSecondSelected ? Colors.grey[400] : Colors.white),
              SizedBox(height: 10),
              _activityContainer('Very Active', 'Around 5 workouts a week', () {
                setState(() {
                  _isFirstSelected = false;
                  _isSecondSelected = false;
                  _isThirdSelected = true;
                  _selectedActivityLevel = 'very_active';
                });
              }, _isThirdSelected ? Colors.grey[400] : Colors.white),

              Spacer(),
              OnboardingButton(
                text: 'Next',
                onPressed: _selectedActivityLevel == null
                    ? () {}
                    : () {
                        widget.setActivityLevel(_selectedActivityLevel!.toUpperCase());
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _activityContainer(text, description, onTap, color) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text(description, style: TextStyle(color: Color(0xFF0C1C24))),
        ],
      ),
    ),
  );
}
