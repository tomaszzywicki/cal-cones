import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingFinal extends StatefulWidget {
  final Function() finishOnboarding;

  // Dane do wyświetlenia w podsumowaniu
  final String? name;
  final DateTime? birthday;
  final String? sex;
  final int? height;
  final double? startWeight;
  final double? targetWeight;
  final String? activityLevel;
  final String? dietType;
  final DateTime? targetDate;

  const OnboardingFinal({
    super.key,
    required this.finishOnboarding,
    this.name,
    this.birthday,
    this.sex,
    this.height,
    this.startWeight,
    this.targetWeight,
    this.activityLevel,
    this.dietType,
    this.targetDate,
  });

  @override
  State<OnboardingFinal> createState() => _OnboardingFinalState();
}

class _OnboardingFinalState extends State<OnboardingFinal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleFinish() async {
    setState(() => _isLoading = true);

    // // Symuluj zapisywanie (możesz dodać prawdziwe zapisywanie tutaj)
    // await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      widget.finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          //
                          // Success Icon
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(36),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                          ),

                          const SizedBox(height: 20),

                          // Title
                          Text(
                            'All Set, ${widget.name ?? "Friend"}!',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Finish button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : OnboardingButton(text: 'Start My Journey', onPressed: _handleFinish),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
