// import 'package:flutter/material.dart';
// import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_list.dart';

// class WeightEntryContainer extends StatelessWidget {
//   const WeightEntryContainer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> pages = [
//       // WeightEntryCalendar(),
//       WeightEntryList(),
//     ];
//     return Card(child: PageView(children: pages));
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_calendar.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_list.dart';

class WeightEntryContainer extends StatefulWidget {
  const WeightEntryContainer({super.key});

  @override
  State<WeightEntryContainer> createState() => _WeightEntryContainerState();
}

class _WeightEntryContainerState extends State<WeightEntryContainer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // Ponieważ ListView w środku ma shrinkWrap: true i NeverScrollable,
      // owijamy SingleChildScrollView, aby karta była przewijalna w ramach PageView
      const SingleChildScrollView(child: WeightEntryList()),
      const SingleChildScrollView(child: WeightEntryCalendar()),
    ];

    // Kolor z theme.dart
    final activeColor = const Color(0xFF0F465D);
    final inactiveColor = Colors.grey.shade300;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Główna karta z zawartością
        SizedBox(
          // Ustalamy wysokość obszaru PageView. Możesz to dostosować.
          height: 450,
          child: PageView(controller: _pageController, onPageChanged: _onPageChanged, children: pages),
        ),

        const SizedBox(height: 12),

        // Wskaźnik stron (Indicator)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
