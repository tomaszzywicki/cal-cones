import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingSex extends StatefulWidget {
  final Function(String name) setSex;
  final String? initialSex;

  const OnboardingSex({super.key, required this.setSex, this.initialSex});

  @override
  State<OnboardingSex> createState() => _OnboardingSexState();
}

class _OnboardingSexState extends State<OnboardingSex> {
  String? _selectedSex;
  bool _isMaleSelected = false;
  bool _isFemaleSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedSex = widget.initialSex;
    if (_selectedSex == 'male') {
      _isMaleSelected = true;
    } else if (_selectedSex == 'female') {
      _isFemaleSelected = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              Text('What is your sex?', style: TextTheme.of(context).headlineLarge),
              SizedBox(height: 100),
              _sexContainer('Male', () {
                setState(() {
                  _isMaleSelected = true;
                  _isFemaleSelected = false;
                  _selectedSex = 'male';
                });
              }, _isMaleSelected ? Colors.grey[400] : Colors.white),
              SizedBox(height: 20),
              _sexContainer('Female', () {
                setState(() {
                  _isMaleSelected = false;
                  _isFemaleSelected = true;
                  _selectedSex = 'female';
                });
              }, _isFemaleSelected ? Colors.grey[400] : Colors.white),
              Spacer(),
              OnboardingButton(
                text: 'Next',
                onPressed: _selectedSex == null
                    ? () {}
                    : () {
                        widget.setSex(_selectedSex!.toUpperCase());
                      },
              ),
            ],
          ),
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
        border: Border.all(color: Colors.grey[500]!, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: color,
        // color: Color(0xFF0F465D),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],
      ),
    ),
  );
}
