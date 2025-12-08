import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingHeight extends StatefulWidget {
  final Function(int height) setHeight;
  final int? initialHeight;

  const OnboardingHeight({super.key, required this.setHeight, this.initialHeight});

  @override
  State<OnboardingHeight> createState() => _OnboardingHeightState();
}

class _OnboardingHeightState extends State<OnboardingHeight> {
  final int minHeight = 100;
  final int maxHeight = 250;
  int selectedHeight = 175;

  late final FixedExtentScrollController _heightController;

  @override
  void initState() {
    super.initState();
    selectedHeight = widget.initialHeight ?? 175;
    _heightController = FixedExtentScrollController(initialItem: selectedHeight - minHeight);
  }

  // @override
  // void dispose() {
  //   _heightController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              SizedBox(height: 100),
              Text('What is your height?', style: TextTheme.of(context).headlineLarge),
              SizedBox(height: 100),

              Stack(
                children: [
                  Container(
                    height: 30,
                    margin: EdgeInsets.only(top: 135),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Container(
                    height: 300,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _heightController,
                            itemExtent: 35,
                            perspective: 0.0005,
                            diameterRatio: 1.2,
                            physics: FixedExtentScrollPhysics(),

                            onSelectedItemChanged: (value) {
                              setState(() => selectedHeight = value + minHeight);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    '${index + minHeight} cm',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                              // jeszcze trzeba będzie lata przestępne dać xd
                              childCount: maxHeight - minHeight + 1,
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
                  widget.setHeight(selectedHeight);
                  print(selectedHeight);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
