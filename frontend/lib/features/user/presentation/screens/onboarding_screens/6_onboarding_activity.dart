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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 100),
            Text('What is your activity level?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 50),
            _activityContainer('Mostly Sedentary', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = true;
                _isSecondSelected = false;
                _isThirdSelected = false;
                _selectedActivityLevel = 'sedentary';
              });
            }, _isFirstSelected ? Colors.grey : Color(0xFFFDF8FE)),
            SizedBox(height: 10),
            _activityContainer('Moderately Active', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = true;
                _isThirdSelected = false;
                _selectedActivityLevel = 'moderately_active';
              });
            }, _isSecondSelected ? Colors.grey : Color(0xFFFDF8FE)),
            SizedBox(height: 10),
            _activityContainer('Very Active', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = false;
                _isThirdSelected = true;
                _selectedActivityLevel = 'very_active';
              });
            }, _isThirdSelected ? Colors.grey : Color(0xFFFDF8FE)),

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
          Text(description, style: TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );
}
