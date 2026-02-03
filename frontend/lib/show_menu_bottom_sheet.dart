import 'package:flutter/material.dart';
import 'package:frontend/core/enums/app_enums.dart';
import 'package:frontend/core/logger/app_logger.dart';
import 'package:frontend/features/ai/presentation/screens/ai_detected_products_page.dart';
import 'package:frontend/features/ai/services/ai_service.dart';
import 'package:frontend/features/product/presentation/screens/product_search_page.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ShowMenuBottomSheet extends StatelessWidget {
  final VoidCallback? onProductAdded;

  const ShowMenuBottomSheet({super.key, this.onProductAdded});

  static void show(BuildContext context, {VoidCallback? onProductAdded}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShowMenuBottomSheet(onProductAdded: onProductAdded),
    );
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
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _OptionCard(
                  icon: Icons.search,
                  title: 'Search',
                  color: Color(0xFFABC9FF),
                  onTap: () => _handleSearchProduct(context, onProductAdded),
                ),
                _OptionCard(
                  icon: Icons.camera_alt,
                  title: 'AI Detect',
                  color: Color(0xFFA3DABB),
                  onTap: () => _handleAIDetect(context, onProductAdded),
                ),
                _OptionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Barcode',

                  color: Color(0xFFFFB5A2),
                  onTap: () => _handleBarcodeScanner(context, onProductAdded),
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
  static Future<void> _handleSearchProduct(BuildContext context, VoidCallback? onSuccess) async {
    final navigator = Navigator.of(context);

    // Zamykamy bottom sheet
    navigator.pop();

    AppLogger.info('Opening ProductSearchPage from bottom sheet.');

    // Czekamy na wynik z ProductSearchPage
    final result = await navigator.push<Map<String, dynamic>?>(
      MaterialPageRoute(builder: (context) => ProductSearchPage(consumedAt: DateTime.now())),
    );

    // 3. Wywołujemy callback jeśli sukces
    if (result != null && result['success'] == true) {
      onSuccess?.call();
    }
  }

  // Handlowanie AI Detect
  // TODO dodać sprawdzenie czy jest połączenie z netem
  // a jeśli jest to i tak dać jakiś timeout max 20 sekund bo jak się wywali serwer to za długo to trwa
  static Future<void> _handleAIDetect(BuildContext context, VoidCallback? onSuccess) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final aiService = Provider.of<AIService>(context, listen: false);

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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

    if (source == null) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);

      if (image == null) return;

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

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Zamknij loader
      }

      if (context.mounted) {
        navigator.pop(); // Zamknij menu bottom sheet
      }

      if (context.mounted) {
        // Czekamy na wynik z AiDetectedProductsPage
        // Zwraca 'true' (bool) jeśli potwierdzono, lub listę map (dla trybu przepisu)
        final result = await navigator.push(
          MaterialPageRoute(
            builder: (context) => AiDetectedProductsPage(image: image, detectedProducts: results),
          ),
        );

        // 4. Wywołujemy callback jeśli sukces
        // Sprawdzamy czy wynik to true (dodano do logu)
        if (result == true) {
          onSuccess?.call();
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Zamknij loader w razie błędu
      }
      AppLogger.error("AI Detect Error: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> _handleBarcodeScanner(BuildContext context, VoidCallback? onSuccess) async {
    final navigator = Navigator.of(context);

    // Zamykamy bottom sheet
    navigator.pop();

    AppLogger.info('Opening ProductSearchPage with Barcode Scanner tab.');

    // Otwieramy ProductSearchPage z tab index 2 (BarcodeScannerTab)
    final result = await navigator.push<Map<String, dynamic>?>(
      MaterialPageRoute(
        builder: (context) => ProductSearchPage(
          consumedAt: DateTime.now(),
          mode: ProductPageMode.add,
          initialTabIndex: 2, // ✅ Barcode tab
        ),
      ),
    );

    // Wywołujemy callback jeśli sukces
    if (result != null && result['success'] == true) {
      onSuccess?.call();
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
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[900], size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
