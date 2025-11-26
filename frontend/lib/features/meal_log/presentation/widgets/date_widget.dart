import 'package:flutter/material.dart';

class DateWidget extends StatelessWidget {
  final String text;
  const DateWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.calendar_month), SizedBox(width: 5), Text(text)],
      ),
    );
  }
}
