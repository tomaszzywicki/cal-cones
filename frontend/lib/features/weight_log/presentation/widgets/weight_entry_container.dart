import 'package:flutter/material.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_calendar.dart';
import 'package:frontend/features/weight_log/presentation/widgets/weight_entry_list.dart';
import 'package:flutter/scheduler.dart';

class MeasureSize extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;

  const MeasureSize({super.key, required this.onChange, required this.child});

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(key: widget.key, child: widget.child);
  }

  void postFrameCallback(_) {
    final context = this.context;
    if (!context.mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      widget.onChange(renderBox.size);
    }
  }
}

class WeightEntryContainer extends StatefulWidget {
  const WeightEntryContainer({super.key});

  @override
  State<WeightEntryContainer> createState() => _WeightEntryContainerState();
}

class _WeightEntryContainerState extends State<WeightEntryContainer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Przechowujemy wysokości dla poszczególnych stron
  // Zakładamy 2 strony: 0 -> Lista, 1 -> Kalendarz
  List<double> _heights = [0.0, 0.0];

  // Pobieramy aktualną wysokość na podstawie aktywnej strony
  double get _currentHeight {
    if (_heights.isEmpty) return 200.0; // Domyślna bezpieczna wartość
    return _heights[_currentPage];
  }

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

  // Funkcja pomocnicza do aktualizacji wysokości konkretnej strony
  void _updateHeight(int index, Size size) {
    // Aktualizujemy tylko jeśli wysokość faktycznie się zmieniła
    if (_heights[index] != size.height) {
      // Używamy addPostFrameCallback, aby uniknąć błędu "setState during build"
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _heights[index] = size.height;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF0F465D);
    final inactiveColor = Colors.grey.shade300;

    // Lista stron
    // WAŻNE: ListView wewnątrz tych widgetów MUSI mieć:
    // shrinkWrap: true oraz physics: NeverScrollableScrollPhysics()
    final List<Widget> pagesContent = [const WeightEntryCalendar(), const WeightEntryList()];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Wskaźnik (Indicator) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pagesContent.length, (index) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // --- Expandable PageView ---
        // Animujemy wysokość kontenera do wysokości aktywnej strony
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _currentHeight > 0 ? _currentHeight : 100, // Zabezpieczenie przed 0
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: pagesContent.length,
            itemBuilder: (context, index) {
              return OverflowBox(
                // OverflowBox jest kluczowy!
                // Pozwala dziecku mieć inną wysokość niż obecny PageView.
                // Ustawiamy minHeight na 0 i maxHeight na nieskończoność,
                // żeby dziecko mogło się w pełni "rozciągnąć" do pomiaru.
                minHeight: 0.7 * MediaQuery.of(context).size.height,
                maxHeight: double.infinity,
                alignment: Alignment.topCenter,
                child: MeasureSize(
                  onChange: (size) => _updateHeight(index, size),
                  child: pagesContent[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
