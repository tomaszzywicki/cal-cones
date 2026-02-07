import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/user/services/user_service.dart';
import 'package:frontend/features/user/data/user_update_model.dart';

class EditActivityLevelScreen extends StatefulWidget {
  final String currentActivity;
  const EditActivityLevelScreen({super.key, required this.currentActivity});

  @override
  State<EditActivityLevelScreen> createState() => _EditActivityLevelScreenState();
}

class _EditActivityLevelScreenState extends State<EditActivityLevelScreen> {
  late String selectedActivity;

  final List<Map<String, String>> activities = [
    {"id": "sedentary", "title": "Sedentary", "desc": "Little or no exercise"},
    {"id": "lightly_active", "title": "Lightly Active", "desc": "1-3 days/week"},
    {"id": "moderately_active", "title": "Moderately Active", "desc": "3-5 days/week"},
    {"id": "very_active", "title": "Very Active", "desc": "6-7 days/week"},
    {"id": "super_active", "title": "Super Active", "desc": "Physical job or professional athlete"},
  ];

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.currentActivity.toLowerCase();
  }

  Future<void> _saveActivity() async {
    final userService = context.read<UserService>();
    try {
      await userService.updateUserActivityLevel(selectedActivity.toUpperCase());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating activity: $e')));
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
          "Activity Level",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                "Your physical activity level",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("How much do you move during the week?", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    bool isSelected = selectedActivity == activity['id'];
                    return GestureDetector(
                      onTap: () => setState(() => selectedActivity = activity['id']!),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isSelected ? Colors.blue : Colors.grey[200]!, width: 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity['title']!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    activity['desc']!,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _saveActivity,
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
