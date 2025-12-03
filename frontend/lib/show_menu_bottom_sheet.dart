import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:frontend/main_screen.dart';

class ShowMenuBottomSheet extends StatelessWidget {
  const ShowMenuBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => const ShowMenuBottomSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OptionCard(
                  icon: Icons.search,
                  title: 'Search',
                  color: Colors.blue,
                  onTap: () => _handleSearchProduct(context),
                ),
                _OptionCard(
                  icon: Icons.camera_alt,
                  title: 'AI Detect',
                  color: Colors.green,
                  onTap: () => _handleAIDetect(context),
                ),
                _OptionCard(
                  icon: Icons.add,
                  title: 'Add Meal',
                  color: Colors.orange,
                  onTap: () => _handleAddMeal(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================== Handlowanie opcji w bottom sheecie ==============================

  // Handlowanie dodawania produktu
  static Future<void> _handleSearchProduct(BuildContext context) async {
    final navigator = Navigator.of(context);

    // 1. Zamykamy bottom sheet
    navigator.pop();

    // 2. Otwieramy ProductSearchPage z DateTime.now()
    AppLogger.info('Opening ProductSearchPage from bottom sheet. Date: ${DateTime.now().toUtc()}');
    final result = await navigator.push<Map<String, dynamic>?>(
      MaterialPageRoute(builder: (context) => ProductSearchPage(consumedAt: DateTime.now().toUtc())),
    );

    // 3. Jeśli produkt został dodany, idziemy do MealLogScreen
    if (result != null && result['success'] == true) {}
  }

  // Handlowanie AI Detect
  static Future<void> _handleAIDetect(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    navigator.pop();
    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('AI Detection coming soon!')));
  }

  // na koniec
  static Future<void> _handleAddMeal(BuildContext context) async {}
}

// ============================== Option Card Widget ==============================

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
