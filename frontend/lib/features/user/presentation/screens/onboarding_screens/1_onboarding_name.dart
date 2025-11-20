import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingName extends StatefulWidget {
  final Function(String name) setName;
  final String? initialName;

  const OnboardingName({super.key, required this.setName, required this.initialName});

  @override
  State<OnboardingName> createState() => _OnboardingNameState();
}

class _OnboardingNameState extends State<OnboardingName> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 150),
            Text('What is your name?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 100),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Your name'),
            ),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  widget.setName(_nameController.text);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
