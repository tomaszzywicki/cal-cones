import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/user/services/user_service.dart';
import 'package:frontend/features/user/presentation/widgets/diet_selection_body.dart';

class EditDietScreen extends StatefulWidget {
  const EditDietScreen({super.key});

  @override
  State<EditDietScreen> createState() => _EditDietScreenState();
}

class _EditDietScreenState extends State<EditDietScreen> {
  String? _tempDietType;
  Map<String, int>? _tempMacros;

  void _handleSave() async {
    if (_tempDietType != null && _tempMacros != null) {
      try {
        await context.read<UserService>().updateUserDiet(dietType: _tempDietType!, macroSplit: _tempMacros!);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating diet: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserService>().currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: 30),
              Expanded(
                child: DietSelectionBody(
                  initialDietType: user?.dietType,
                  initialMacroSplit: user?.macroSplit?.map((key, value) => MapEntry(key, value.toInt())),
                  onDataChanged: (name, macros) {
                    setState(() {
                      _tempDietType = name;
                      _tempMacros = macros;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_tempDietType == null) {
                        setState(() {
                          _tempDietType = user?.dietType;
                        });
                      }
                      if (_tempMacros == null) {
                        setState(() {
                          _tempMacros = user?.macroSplit?.map((key, value) => MapEntry(key, value.toInt()));
                        });
                      }
                      _handleSave();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
