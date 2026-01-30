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
  String? _selectedDietType;
  Map<String, int>? _macroSplit;
  bool _isFirstSelected = false;
  bool _isSecondSelected = false;
  bool _isThirdSelected = false;

  @override
  void initState() {
    super.initState();
    
    final initial = widget.initialDietType;
    if (initial != null) {
      _selectedDietType = initial.toLowerCase();
      _macroSplit = widget.initialMacroSplit;
      
      _isFirstSelected = _selectedDietType == 'balanced';
      _isSecondSelected = _selectedDietType == 'low_carb';
      _isThirdSelected = _selectedDietType == 'low_fat';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 100),
            Text('What is your diet type?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 50),
            _dietContainer('Balanced', 'Optimal balance for general health', () {
              setState(() {
                _isFirstSelected = true;
                _isSecondSelected = false;
                _isThirdSelected = false;
                _selectedDietType = 'balanced';
                _macroSplit = {"Carbs": 40, "Protein": 30, "Fat": 30};
              });
            }, _isFirstSelected ? Colors.grey[400] : Colors.white),
            SizedBox(height: 10),
            _dietContainer('Low Carb', 'Higher fats & protein, limited carbs', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = true;
                _isThirdSelected = false;
                _selectedDietType = 'low_carb';
                _macroSplit = {"Carbs": 10, "Protein": 30, "Fat": 60};
              });
            }, _isSecondSelected ? Colors.grey[400] : Colors.white),
            SizedBox(height: 10),
            _dietContainer('Low Fat', 'Higher carbs & protein, limited fats', () {
              setState(() {
                _isFirstSelected = false;
                _isSecondSelected = false;
                _isThirdSelected = true;
                _selectedDietType = 'low_fat';
                _macroSplit = {"Carbs": 60, "Protein": 30, "Fat": 10};
              });
            }, _isThirdSelected ? Colors.grey[400] : Colors.white),

            SizedBox(height: 20),

            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: _selectedDietType == null || _macroSplit == null
                  ? () {}
                  : () {
                      widget.setDietAndMacro(_selectedDietType!.toUpperCase(), _macroSplit!);
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
