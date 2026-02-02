import 'dart:math' as math;
import 'package:flutter/material.dart';

class TempoGauge extends StatelessWidget {
  final double tempo;
  final double minTempo;
  final double maxTempo;
  final double size;

  const TempoGauge({
    super.key,
    required this.tempo,
    this.minTempo = 0.0,
    this.maxTempo = 1.2,
    this.size = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minTempo, end: tempo),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          // Wysokość to połowa szerokości + margines na grubość linii (ok 10-15%)
          height: (size / 2) + (size * 0.12),
          child: CustomPaint(
            painter: _TempoGaugePainter(currentValue: value, minValue: minTempo, maxValue: maxTempo),
          ),
        );
      },
    );
  }
}

class _TempoGaugePainter extends CustomPainter {
  final double currentValue;
  final double minValue;
  final double maxValue;

  _TempoGaugePainter({required this.currentValue, required this.minValue, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Wszystkie wymiary bazują na przekazanym size.width
    final strokeWidth = size.width * 0.12;
    final capRadius = strokeWidth / 2;

    // Punkt środkowy przesunięty o promień zaokrąglenia, aby nie wyjść poza płótno
    final center = Offset(size.width / 2, size.height - capRadius - (size.width * 0.02));
    final radius = (size.width / 2) - capRadius;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Łuk gradientowy
    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: const [
        Color(0xFF81C784), // Zielony
        Color(0xFFFFEE58), // Żółty
        Color(0xFFFFA726), // Pomarańczowy
        Color(0xFFEF5350), // Czerwony
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    ).createShader(rect);

    final arcPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, math.pi, math.pi, false, arcPaint);

    // 2. Kropki na końcach łuku (Caps) - opcjonalne, dla lepszego wypełnienia koloru na start/end
    canvas.drawCircle(
      Offset(center.dx - radius, center.dy),
      capRadius,
      Paint()..color = const Color(0xFF81C784),
    );
    canvas.drawCircle(
      Offset(center.dx + radius, center.dy),
      capRadius,
      Paint()..color = const Color(0xFFEF5350),
    );

    // 3. Wskazówka
    final double normalized = ((currentValue - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final needleAngle = math.pi + (normalized * math.pi);

    final needleLength = radius * 0.7;
    final needleX = center.dx + needleLength * math.cos(needleAngle);
    final needleY = center.dy + needleLength * math.sin(needleAngle);

    final needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(needleX, needleY), needlePaint);

    // 4. Kropka centralna (oś)
    final centerDotRadius = size.width * 0.08;
    canvas.drawCircle(center, centerDotRadius, Paint()..color = Colors.black87);
    canvas.drawCircle(center, centerDotRadius * 0.4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _TempoGaugePainter oldDelegate) {
    return oldDelegate.currentValue != currentValue;
  }
}
