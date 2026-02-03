import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingWeight extends StatefulWidget {
  final Function(double weight) setWeight;
  final double? initialWeight;
  final String? sex;

  const OnboardingWeight({
    super.key,
    required this.setWeight,
    this.initialWeight,
    this.sex,
  });

  @override
  State<OnboardingWeight> createState() => _OnboardingWeightState();
}

class _OnboardingWeightState extends State<OnboardingWeight> {
  final int minWeight = 30;
  final int maxWeight = 200;

  late int selectedInt;
  late int selectedDecimal;

  late final FixedExtentScrollController _intController;
  late final FixedExtentScrollController _decimalController;

  @override
  void initState() {
    super.initState();

    double startVal;

    if (widget.initialWeight != null) {
      startVal = widget.initialWeight!;
    } else {
      // Default logic based on gender
      if (widget.sex == 'Male') {
        startVal = 75.0;
      } else if (widget.sex == 'Female') {
        startVal = 50.0;
      } else {
        startVal = 60.0; // Fallback if sex is not selected or unknown
      }
    }

    selectedInt = startVal.floor();
    // Calculate decimal part (e.g., 70.5 -> 5)
    selectedDecimal = ((startVal - selectedInt) * 10).round();

    // Ensure within bounds
    if (selectedInt < minWeight) selectedInt = minWeight;
    if (selectedInt > maxWeight) selectedInt = maxWeight;

    _intController = FixedExtentScrollController(initialItem: selectedInt - minWeight);
    _decimalController = FixedExtentScrollController(initialItem: selectedDecimal);
  }

  @override
  void dispose() {
    _intController.dispose();
    _decimalController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 100),
              Text(
                'What is your weight?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 100),

              Stack(
                alignment: Alignment.center,
                children: [
                  // Grey highlight bar
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 8), // slightly adjusted for visual alignment
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Pickers Row
                  SizedBox(
                    height: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Integer Part Wheel
                        SizedBox(
                          width: 70,
                          child: ListWheelScrollView.useDelegate(
                            controller: _intController,
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (value) {
                              setState(() => selectedInt = value + minWeight);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: maxWeight - minWeight + 1,
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    '${index + minWeight}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        // Dot separator
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '.',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Decimal Part Wheel
                        SizedBox(
                          width: 50,
                          child: ListWheelScrollView.useDelegate(
                            controller: _decimalController,
                            itemExtent: 50,
                            perspective: 0.005,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (value) {
                              setState(() => selectedDecimal = value);
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 10, // 0 to 9
                              builder: (context, index) {
                                return Center(
                                  child: Text(
                                    '$index',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Unit Label
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'kg',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),
              
              OnboardingButton(
                text: 'Next',
                onPressed: () {
                  final double finalWeight = selectedInt + (selectedDecimal / 10);
                  widget.setWeight(finalWeight);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}