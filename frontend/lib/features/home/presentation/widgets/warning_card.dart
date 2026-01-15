import 'package:flutter/material.dart';

class WarningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final MaterialColor color;
  final String buttonText;
  final VoidCallback buttonAction;
  final VoidCallback? onAction;

  const WarningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.buttonText,
    required this.buttonAction,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAction,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Margines dolny dla odstępu
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color[50], // Bardzo jasne tło
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color[200]!), // Subtelna ramka
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color[700], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color[900], fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: color[900]!.withOpacity(0.8), fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: buttonAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: color, // Pełny kolor przycisku
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(80, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
              ),
              child: Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
