import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingGoalType extends StatefulWidget {
  final Function(String type) setGoalType;

  const OnboardingGoalType({super.key, required this.setGoalType});

  @override
  State<OnboardingGoalType> createState() => _OnboardingGoalTypeState();
}

class _OnboardingGoalTypeState extends State<OnboardingGoalType> {
  String? _selectedGoalType;
  bool _isFirstSelected = false;
  bool _isSecondSelected = false;
  bool _isThirdSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 100),
            Text('What is your goal?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 50),
            _goalType('Lose weight', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = true;
                _isSecondSelected = false;
                _isThirdSelected = false;
                _selectedGoalType = 'Standard';
              });
            }, _isFirstSelected ? Colors.grey : Color(0xFFFDF8FE)),
            SizedBox(height: 10),
            _goalType('Maintain Weight', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = true;
                _isThirdSelected = false;
                _selectedGoalType = 'Low Carb';
              });
            }, _isSecondSelected ? Colors.grey : Color(0xFFFDF8FE)),
            SizedBox(height: 10),
            _goalType('Lose weight', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = false;
                _isThirdSelected = true;
                _selectedGoalType = 'Low Fat';
              });
            }, _isThirdSelected ? Colors.grey : Color(0xFFFDF8FE)),

            SizedBox(height: 20),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: _selectedGoalType == null
                  ? () {}
                  : () {
                      widget.setGoalType(_selectedGoalType!);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _goalType(text, description, onTap, color) {
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
