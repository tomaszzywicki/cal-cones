import 'package:flutter/material.dart';

class CurrentGoalCard extends StatelessWidget {
  const CurrentGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2 - 16,
        height: 100,
        child: Center(child: Text('current goal')),
      ),
    );
  }
}
