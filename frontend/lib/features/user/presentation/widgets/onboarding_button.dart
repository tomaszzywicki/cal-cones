import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/core/theme/theme.dart';

class OnboardingButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OnboardingButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      // style: Theme.of(context)
      child: Text(text),
      // child: Text(
      //   text,
      //   style: TextTheme.of(
      //     context,
      //   ).bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      // ),
    );
  }
}
