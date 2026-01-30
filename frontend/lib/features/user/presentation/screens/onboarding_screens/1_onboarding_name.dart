import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingName extends StatefulWidget {
  final Function(String name) setName;
  final String? initialName;

  const OnboardingName({super.key, required this.setName, this.initialName});

  @override
  State<OnboardingName> createState() => _OnboardingNameState();
}

class _OnboardingNameState extends State<OnboardingName> {
  late TextEditingController _nameController;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  void validateName() {
    setState(() {
      _isValid = _nameController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        // This ensures the body resizes when keyboard opens
        resizeToAvoidBottomInset: true, 
        body: SafeArea(
          child: Column(
            children: [
              // This Expanded section will shrink when keyboard opens
              Expanded(
                child: Center( 
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Removed huge hardcoded SizedBox(height: 150)
                        Text(
                          'What is your name?', 
                          style: TextTheme.of(context).headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60), // Reduced spacing to fit better
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Your name',
                            // Optional: Add a border or fill for better visibility
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleNext(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Button stays pinned to the bottom (or top of keyboard)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: OnboardingButton(text: 'Next', onPressed: _handleNext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNext() async {
    validateName();

    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name'), duration: Duration(seconds: 2)),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      widget.setName(_nameController.text.trim());
    }
  }
}