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
    this.maxTempo = 1.5,
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
          height: size / 2 + 10,
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
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Łuk gradientowy (Tło)
    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: const [
        Color(0xFF81C784), // Zielony (Spokojne tempo)
        Color(0xFFFFEE58), // Żółty
        Color(0xFFFFA726), // Pomarańczowy
        Color(0xFFEF5350), // Czerwony (Agresywne tempo)
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    ).createShader(rect);

    final arcPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    // Rysujemy łuk od 180 stopni (pi) do 360 stopni (2pi)
    canvas.drawArc(rect, math.pi, math.pi, false, arcPaint);

    // 2. Kropki na końcach łuku (Caps)
    final capRadius = 6.0;
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
    // Normalizujemy wartość 0..1
    final double normalized = ((currentValue - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);

    // Kąt: startujemy od PI (lewa strona), dodajemy znormalizowaną wartość * PI
    final needleAngle = math.pi + (normalized * math.pi);

    final needleLength = radius - 15;
    final needleX = center.dx + needleLength * math.cos(needleAngle);
    final needleY = center.dy + needleLength * math.sin(needleAngle);

    final needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Rysujemy linię wskazówki
    canvas.drawLine(center, Offset(needleX, needleY), needlePaint);

    // Kropka centralna (oś wskazówki)
    canvas.drawCircle(center, 8, Paint()..color = Colors.black87);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _TempoGaugePainter oldDelegate) {
    return oldDelegate.currentValue != currentValue;
  }
}
