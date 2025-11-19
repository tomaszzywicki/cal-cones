import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingWeight extends StatefulWidget {
  final Function(double weight) setWeight;

  const OnboardingWeight({super.key, required this.setWeight});

  @override
  State<OnboardingWeight> createState() => _OnboardingWeightState();
}

class _OnboardingWeightState extends State<OnboardingWeight> {
  final TextEditingController _nameController = TextEditingController();

  double _weight = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 150),
            Text('What is your weight?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Tu ogólnie też tak jak birthday ma być'),
            SizedBox(height: 100),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Weight'),
              keyboardType: TextInputType.numberWithOptions(),
            ),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: () {
                widget.setWeight(_weight);
              },
            ),
          ],
        ),
      ),
    );
  }
}
