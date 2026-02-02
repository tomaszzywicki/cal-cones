import 'package:flutter/material.dart';

class GoalWarningDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const GoalWarningDialog({super.key, required this.onConfirm});

  @override
  State<GoalWarningDialog> createState() => _GoalWarningDialogState();
}

class _GoalWarningDialogState extends State<GoalWarningDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: Colors.red.shade900.withOpacity(0.5), width: 1.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nagłówek z ikoną i tytułem
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                color: Colors.red.shade700,
                child: const Column(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.white, size: 54),
                    SizedBox(height: 12),
                    Text(
                      "Replace Current Goal?",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Treść i przyciski
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  children: [
                    const Text(
                      "Setting a new goal will archive your current progress and permanently close the active goal.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        height: 1.4,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tip Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.orange.shade800, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Make sure to record your current weight first. This affects both the old and new goal's history.",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Przycisk potwierdzenia
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Confirm & Replace",
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Przycisk powrotu
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Nevermind, go back",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
