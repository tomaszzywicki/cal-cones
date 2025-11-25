import 'package:flutter/material.dart';

class DateWidget extends StatelessWidget {
  final String text;
  const DateWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(child: Row(children: [Icon(Icons.calendar_month), Text(text)]));
  }
}
