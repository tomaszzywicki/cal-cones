import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';
import 'package:frontend/features/user/presentation/widgets/diet_selection_body.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDietType = widget.initialDietType;
    _macroSplit = widget.initialMacroSplit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Expanded(
                child: DietSelectionBody(
                  initialDietType: widget.initialDietType,
                  initialMacroSplit: widget.initialMacroSplit,
                  onDataChanged: (name, macros) {
                    setState(() {
                      _selectedDietType = name;
                      _macroSplit = macros;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              OnboardingButton(
                text: 'Next',
                onPressed: _selectedDietType == null
                    ? () {
                        _selectedDietType = "BALANCED";
                        _macroSplit = {"protein": 30, "carbs": 40, "fats": 30};
                        widget.setDietAndMacro(_selectedDietType!, _macroSplit!);
                      }
                    : () {
                        widget.setDietAndMacro(_selectedDietType!, _macroSplit ?? {});
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
