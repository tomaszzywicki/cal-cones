import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/dashboard/presentation/screens/bmi_card.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.offset >= (_scrollController.position.maxScrollExtent - 20);
    if (atBottom != _isAtBottom) {
      setState(() {
        _isAtBottom = atBottom;
      });
    }
  }

  void _goToInfoPage() {
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    _currentPage = 1;
  }

  void _goToMainPage() {
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    _currentPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Details')),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [_buildMainPage(context), _buildInfoPage(context)],
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _currentPage == 0 ? _goToInfoPage : _goToMainPage,
                icon: const Icon(Icons.info_outline),
                label: _currentPage == 0 ? const Text("Learn More about BMI") : const Text("What is my BMI?"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPageIndicator(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- STRONA 1: Główny widok ---
  Widget _buildMainPage(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BMIcard(isExpanded: true),
              const SizedBox(height: 30),

              Text(
                "What is BMI?",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Body Mass Index (BMI) is a widely used health indicator that estimates obesity level based on a person's height and weight. It serves as a simple screening tool to identify potential health risks.\n\nIn general population, significantly elevated levels are linked to heart disease and diabetes.",
                      textAlign: TextAlign.justify,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.grey[600], size: 25),
                        const SizedBox(height: 8),
                        Text(
                          "Please note, that BMI does not distinguish between muscle and fat mass. Particularly fit individuals or athletes may register a higher BMI despite having low body fat.",
                          textAlign: TextAlign.justify,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.5),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
        ),

        // WARSTWA 2: Przycisk (Klikalny - leży NA gradiencie)
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (_scrollController.hasClients) {
                  final position = _isAtBottom ? 0.0 : _scrollController.position.maxScrollExtent;
                  _scrollController.animateTo(
                    position,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: AnimatedRotation(
                  turns: _isAtBottom ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutBack,
                  child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700], size: 30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- STRONA 2: Legenda i Kalkulacje ---
  Widget _buildInfoPage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BMI Categories",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildLegendRow(context, "Underweight", "less than 18.5", Colors.blue),
          _buildLegendRow(context, "Normal weight", "18.5 – 25", Colors.green),
          _buildLegendRow(context, "Overweight", "25 – 30", Colors.orange),
          _buildLegendRow(context, "Obese", "30 or more", Colors.red),

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),

          Text(
            "How is it calculated?",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("weight (kg)", style: Theme.of(context).textTheme.titleMedium),
                    Container(
                      height: 2,
                      width: 100,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    Text("height (m)²", style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(width: 20),
                const Text("=", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                const Text(
                  "BMI",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xff44638b)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "The BMI calculation divides an adult's weight in kilograms by their height in meters squared. For example, a BMI of 25 means 25kg/m².",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(BuildContext context, String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(range, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --- Kropeczki na dole ---
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 10,
          width: _currentPage == index ? 20 : 10,
          decoration: BoxDecoration(
            color: _currentPage == index ? const Color(0xff44638b) : Colors.grey[400],
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}
