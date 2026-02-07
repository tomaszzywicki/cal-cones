import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/user/services/user_service.dart';
import 'package:frontend/features/user/data/user_update_model.dart';

class EditSexScreen extends StatefulWidget {
  final String currentSex;
  const EditSexScreen({super.key, required this.currentSex});

  @override
  State<EditSexScreen> createState() => _EditSexScreenState();
}

class _EditSexScreenState extends State<EditSexScreen> {
  late String selectedSex;

  @override
  void initState() {
    super.initState();
    selectedSex = widget.currentSex;
  }

  Future<void> _saveSex() async {
    final userService = context.read<UserService>();
    try {
      await userService.updateUserSex(selectedSex);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating sex: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Sex",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text("What is your sex?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "We use this to calculate your daily caloric and macronutrient needs.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _sexCard("male", Icons.male, Colors.blue),
                      const SizedBox(width: 20),
                      _sexCard("female", Icons.female, Colors.pink),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveSex,
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

  Widget _sexCard(String sex, IconData icon, Color color) {
    bool isSelected = selectedSex == sex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSex = sex),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: isSelected ? color : Colors.grey),
              const SizedBox(height: 10),
              Text(
                sex.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
