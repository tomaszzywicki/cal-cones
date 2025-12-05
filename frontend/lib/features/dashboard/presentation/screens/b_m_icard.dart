import 'package:flutter/material.dart';

class BMIcard extends StatelessWidget {
  const BMIcard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: Center(child: Text('BMI card')),
      ),
    );
  }
}
