import 'package:flutter/material.dart';

class WeighInCalendarCard extends StatelessWidget {
  const WeighInCalendarCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2 - 16,
        height: 100,
        child: Center(child: Text('weigh-in calendar')),
      ),
    );
  }
}
