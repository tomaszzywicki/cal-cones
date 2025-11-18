import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';

class BasicInfo extends StatefulWidget {
  const BasicInfo({super.key});

  @override
  State<BasicInfo> createState() => _BasicInfoState();
}

class _BasicInfoState extends State<BasicInfo> {
  final TextEditingController _nameController = TextEditingController();
  DateTime _birthDay = DateTime(2000, 1, 1);

  void _changeBirthDay(DateTime? newBirthDay) {
    if (newBirthDay == null) {
      AppLogger.debug("Ignoring an attempt to set birthday to null");
      return;
    }
    setState(() => _birthDay = newBirthDay);
    AppLogger.debug(_birthDay.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('What is your name?'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "Display name"),
              ),
              SizedBox(height: 50),
              Text('What is your birthday?'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // style: ElevatedButton.styleFrom(
                  //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  // ),,
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      helpText: "Choose your birth date",
                    );
                    _changeBirthDay(pickedDate);
                  },
                  child: Text(
                    "${_birthDay.day}/${_birthDay.month.toString().padLeft(2, '0')}/${_birthDay.year}",
                    // style:
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
