import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OnboardingButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
        backgroundColor: Color(0xFF101010),
        foregroundColor: Colors.white,
        elevation: 2, // to chyba cień
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4)),
      ),
      child: Text(text),
    );
  }
}
