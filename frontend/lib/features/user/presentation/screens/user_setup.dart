import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';

class UserSetup extends StatefulWidget {
  const UserSetup({super.key});

  @override
  State<UserSetup> createState() => _UserSetupState();
}

class _UserSetupState extends State<UserSetup> {
  final _nameController = TextEditingController();
  DateTime _birthDatetime = DateTime.timestamp();

  void _changeBirthDatetime(DateTime newBirthDatetime) {
    _birthDatetime = newBirthDatetime;
    AppLogger.debug(_birthDatetime.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Basic info"),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(hintText: "Display name"),
            ),
            CalendarDatePicker(
              initialDate: DateTime(2000, 4, 10),
              firstDate: DateTime(1900, 1, 1),
              lastDate: DateTime(2025, 1, 1),
              onDateChanged: _changeBirthDatetime,
            ),
          ],
        ),
      ),
    );
  }
}
