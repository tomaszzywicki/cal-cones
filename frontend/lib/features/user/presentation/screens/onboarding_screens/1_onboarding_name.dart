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
      onTap: () => FocusScope.of(context).unfocus(), // to żeby ukryć klawiaturę po kliknięciu na ekran
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        const SizedBox(height: 150),
                        Text('What is your name?', style: TextTheme.of(context).headlineLarge),
                        const SizedBox(height: 100),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'Your name'),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleNext(),
                        ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                      ],
                    ),
                  ),
                ),

                Spacer(),
                OnboardingButton(text: 'Next', onPressed: _handleNext),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext() async {
    validateName();

    if (!_isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name'), duration: Duration(seconds: 2)));
      return;
    }

    // Ukrycie klawiaturę
    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      widget.setName(_nameController.text.trim());
    }
  }
}
