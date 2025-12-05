import 'package:flutter/material.dart';

class MacroLine extends StatelessWidget {
  final String name;
  final Color color;
  final double value;
  final double endValue;

  const MacroLine({required this.name, required this.color, required this.value, required this.endValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 16,
          child: Center(
            child: Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: value / endValue,
          color: color,
          backgroundColor: color.withValues(alpha: 0.2),
          minHeight: 5,
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 14,
          child: Center(
            child: Text(
              '${value.toInt()} / ${endValue.toInt()}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
