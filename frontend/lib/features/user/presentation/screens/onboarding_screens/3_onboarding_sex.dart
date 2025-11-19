import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingSex extends StatefulWidget {
  final Function(String name) setName;

  const OnboardingSex({super.key, required this.setName});

  @override
  State<OnboardingSex> createState() => _OnboardingSexState();
}

class _OnboardingSexState extends State<OnboardingSex> {
  String? _selectedSex;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 100),
            Text('What is your sex?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 100),
            _sexContainer('Male', () {
              setState(() {
                _isMaleSelected = true;
                _isFemaleSelected = false;
                _selectedSex = 'Male';
              });
            }, _isMaleSelected ? Colors.grey : Color(0xFFFDF8FE)),
            SizedBox(height: 20),
            _sexContainer('Female', () {
              setState(() {
                _isMaleSelected = false;
                _isFemaleSelected = true;
                _selectedSex = 'Female';
              });
            }, _isFemaleSelected ? Colors.grey : Color(0xFFFDF8FE)),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: _selectedSex == null
                  ? () {}
                  : () {
                      widget.setName(_selectedSex!);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _sexContainer(text, onTap, color) {
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
        children: [Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],
      ),
    ),
  );
}
