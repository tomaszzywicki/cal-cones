import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingWeight extends StatefulWidget {
  final Function(double weight) setWeight;
  final double? initialWeight;

  const OnboardingWeight({super.key, required this.setWeight, this.initialWeight});

  @override
  State<OnboardingWeight> createState() => _OnboardingWeightState();
}

class _OnboardingWeightState extends State<OnboardingWeight> {
  late TextEditingController _weightController;

  double _weight = 70;

  @override
  void initState() {
    super.initState();
    _weight = widget.initialWeight ?? 70;
    _weightController = TextEditingController();
    _weightController.text = _weight.toString();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
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
            SizedBox(height: 150),
            Text('What is your weight?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Tu ogólnie też tak jak birthday ma być'),
            SizedBox(height: 80),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(hintText: 'Weight'),
              keyboardType: TextInputType.numberWithOptions(),
            ),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: () {
                widget.setWeight(double.parse(_weightController.text));
              },
            ),
          ],
        ),
      ),
    );
  }
}
