import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnbboardingGoalData extends StatefulWidget {
  final Function(DateTime startDate, DateTime targetDate, double targetWeight, double tempo) setGoalData;

  const OnbboardingGoalData({super.key, required this.setGoalData});

  @override
  State<OnbboardingGoalData> createState() => _OnbboardingGoalDataState();
}

class _OnbboardingGoalDataState extends State<OnbboardingGoalData> {
  String _goalRatename = 'Standard (Recommended)';
  DateTime _startDate = DateTime.now().toUtc();
  DateTime? _targetDate;
  double? _targetWeight;
  double? _tempo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            Row(children: []),
            SizedBox(height: 15),
            Text('What is your target weight?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('*Tutaj suwak*'),
            SizedBox(height: 10),
            Text(
              'What is your target weight change?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(_goalRatename),
            SizedBox(height: 5),
            Text('*Tutaj slider do rate*'),
            SizedBox(height: 10),
            Text('*No i tu jakieś wizualizacje tego*'),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: () {
                widget.setGoalData(_startDate, _targetDate!, _targetWeight!, _tempo!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
