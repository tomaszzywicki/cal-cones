import 'package:flutter/material.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/ai/presentation/screens/ai_detected_products_page.dart';
import 'package:frontend/features/ai/services/ai_service.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

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
  // TODO dodać sprawdzenie czy jest połączenie z netem
  // a jeśli jest to i tak dać jakiś timeout max 20 sekund bo jak się wywali serwer to za długo to trwa
  static Future<void> _handleAIDetect(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final aiService = Provider.of<AIService>(context, listen: false);

    // 1. Ask user for source (Camera or Gallery)
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    // If user cancelled selection (clicked outside), return
    if (source == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      // Use the selected source here
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);

      // User cancelled camera/gallery picker
      if (image == null) {
        return;
      }

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Analyzing food...")],
                ),
              ),
            ),
          ),
        );
      }

      final results = await aiService.detectProducts(image);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Close the main menu bottom sheet
      if (context.mounted) {
        navigator.pop();
      }

      if (context.mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => AiDetectedProductsPage(image: image, detectedProducts: results),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if error occurs
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      AppLogger.error("AI Detect Error: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e'), backgroundColor: Colors.red),
      );
    }
  }
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
