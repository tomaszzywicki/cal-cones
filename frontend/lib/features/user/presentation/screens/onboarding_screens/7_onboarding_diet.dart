import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingDiet extends StatefulWidget {
  final Function(String name, Map<String, int>) setDietAndMacro;
  final String? initialDietType;
  final Map<String, int>? initialMacroSplit;

  const OnboardingDiet({
    super.key,
    required this.setDietAndMacro,
    this.initialDietType,
    this.initialMacroSplit,
  });

  @override
  State<OnboardingDiet> createState() => _OnboardingDietState();
}

class _OnboardingDietState extends State<OnboardingDiet> {
  String? _selectedActivityLevel;
  Map<String, int>? _macroSplit;
  bool _isFirstSelected = false;
  bool _isSecondSelected = false;
  bool _isThirdSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDietType != null) {
      _selectedActivityLevel = widget.initialDietType;
      _macroSplit = widget.initialMacroSplit;
      _isFirstSelected = _selectedActivityLevel == 'Standard';
      _isSecondSelected = _selectedActivityLevel == 'Low Carb';
      _isThirdSelected = _selectedActivityLevel == 'Low Fat';
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
            Text('What is your diet type?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 50),
            _dietContainer('Standard', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = true;
                _isSecondSelected = false;
                _isThirdSelected = false;
                _selectedActivityLevel = 'Standard';
                _macroSplit = {"Carbs": 40, "Protein": 30, "Fat": 30};
              });
            }, _isFirstSelected ? Colors.grey : Color(0xFFFDF8FE)),
            SizedBox(height: 10),
            _dietContainer('Low Carb', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = true;
                _isThirdSelected = false;
                _selectedActivityLevel = 'Low Carb';
                _macroSplit = {"Carbs": 10, "Protein": 30, "Fat": 60};
              });
            }, _isSecondSelected ? Colors.grey : Color(0xFFFDF8FE)),
            SizedBox(height: 10),
            _dietContainer('Low Fat', 'Jakiś tam opis 1', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = false;
                _isThirdSelected = true;
                _selectedActivityLevel = 'Low Fat';
                _macroSplit = {"Carbs": 60, "Protein": 30, "Fat": 10};
              });
            }, _isThirdSelected ? Colors.grey : Color(0xFFFDF8FE)),

            SizedBox(height: 20),

            Text('*Tutaj pasek kolorowy że 50/30/30*'),

            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: _selectedActivityLevel == null || _macroSplit == null
                  ? () {}
                  : () {
                      widget.setDietAndMacro(_selectedActivityLevel!, _macroSplit!);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _dietContainer(text, description, onTap, color) {
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
