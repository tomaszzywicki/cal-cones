import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/basic_info.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/goal_setup.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/onboarding_summary.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/physical_data.dart';
import 'package:frontend/features/user/presentation/screens/onboarding_screens/training_data.dart';
import 'package:frontend/main_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:frontend/core/logger/app_logger.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _Onboarding();
}

class _Onboarding extends State<Onboarding> {
  PageController _pageController = PageController();
  bool onFirstPage = true;
  bool onLastPage = false;

  final List<Widget> pages = [BasicInfo(), PhysicalData(), TrainingData(), GoalSetup(), OnboardingSummary()];

  void _saveOnboardingInfo() {
    AppLogger.debug("saving onbording info");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                onFirstPage = (index == 0);
                onLastPage = (index == pages.length - 1);
              });
            },
            children: pages,
          ),

          Container(
            alignment: Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onFirstPage
                      ? null
                      : () {
                          _pageController.previousPage(
                            duration: Duration(microseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        },
                  child: Text("Back"),
                ),

                // progress indicator (dots on the screen)
                SmoothPageIndicator(controller: _pageController, count: pages.length),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onLastPage
                      ? () {
                          _saveOnboardingInfo();
                        }
                      : () {
                          _pageController.nextPage(
                            duration: Duration(microseconds: 200),
                            curve: Curves.easeInOut,
                          );
                        },
                  child: onLastPage ? Text("Done") : Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
