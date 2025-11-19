import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingBirthday extends StatefulWidget {
  final Function(int day, int month, int year) setBirthday;

  const OnboardingBirthday({super.key, required this.setBirthday});

  @override
  State<OnboardingBirthday> createState() => _OnboardingBirthdayState();
}

class _OnboardingBirthdayState extends State<OnboardingBirthday> {
  final _dayController = FixedExtentScrollController(initialItem: 15);
  final _monthController = FixedExtentScrollController(initialItem: 6);
  final _yearController = FixedExtentScrollController(initialItem: 100);

  int selectedDay = 15;
  int selectedMonth = 6;
  int selectedYear = 2000;

  final List<String> _monthList = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            SizedBox(height: 50),
            Text('When were you born?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 100),

            Stack(
              children: [
                Container(
                  height: 30,
                  margin: EdgeInsets.only(top: 135),
                  decoration: BoxDecoration(
                    color: CupertinoColors.secondarySystemBackground,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  height: 300,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _dayController,
                          itemExtent: 45,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: FixedExtentScrollPhysics(),

                          onSelectedItemChanged: (value) {
                            setState(() => selectedDay = value + 1);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                            // jeszcze trzeba będzie lata przestępne dać xd
                            childCount: selectedMonth == 2
                                ? 28
                                : ([1, 3, 5, 7, 8, 10, 12].contains(selectedMonth) ? 31 : 30),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _monthController,
                          itemExtent: 45,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: FixedExtentScrollPhysics(),

                          onSelectedItemChanged: (value) {
                            setState(() => selectedMonth = value + 1);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  '${_monthList[index]}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                            childCount: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _yearController,
                          itemExtent: 45,
                          perspective: 0.005,
                          diameterRatio: 1.2,
                          physics: FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (value) {
                            setState(() => selectedYear = value + 1900);
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              return Center(
                                child: Text(
                                  '${index + 1900}',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                            childCount: 125,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            OnboardingButton(
              text: 'Next',
              onPressed: () {
                widget.setBirthday(selectedDay, selectedMonth, selectedYear);
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
