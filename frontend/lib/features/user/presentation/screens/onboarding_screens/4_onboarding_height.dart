import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingHeight extends StatefulWidget {
  final Function(int height) setHeight;

  const OnboardingHeight({super.key, required this.setHeight});

  @override
  State<OnboardingHeight> createState() => _OnboardingHeightState();
}

class _OnboardingHeightState extends State<OnboardingHeight> {
  final TextEditingController _nameController = TextEditingController();

  int _height = 175;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 150),
            Text('What is your height?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Text('Tu ogólnie też tak jak birthday ma być'),
            SizedBox(height: 100),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Height'),
              keyboardType: TextInputType.numberWithOptions(),
            ),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: () {
                widget.setHeight(_height);
              },
            ),
          ],
        ),
      ),
    );
  }
}
