import 'package:flutter/material.dart';

class BasicInfo extends StatelessWidget {
  const BasicInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Basic info")));
    // TextEditingController _nameController = TextEditingController();
    // DateTime _birthDatetime = DateTime.timestamp();

    // void _changeBirthDatetime(DateTime newBirthDatetime) {
    //   _birthDatetime = newBirthDatetime;
    //   AppLogger.debug(_birthDatetime.toString());
    // }

    // return Scaffold(
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Text("Basic info"),
    //         TextFormField(
    //           controller: _nameController,
    //           decoration: InputDecoration(hintText: "Display name"),
    //         ),
    //         CalendarDatePicker(
    //           initialDate: DateTime(2000, 4, 10),
    //           firstDate: DateTime(1900, 1, 1),
    //           lastDate: DateTime(2025, 1, 1),
    //           onDateChanged: _changeBirthDatetime,
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
