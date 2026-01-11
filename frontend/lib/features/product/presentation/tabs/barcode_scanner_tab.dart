import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/enums/app_enums.dart';
import '../../services/open_food_facts_service.dart';
import '../screens/product_details_page.dart';

class BarcodeScannerTab extends StatefulWidget {
  final DateTime consumedAt;
  final ProductPageMode mode;

  const BarcodeScannerTab({super.key, required this.consumedAt, required this.mode});

  @override
  State<BarcodeScannerTab> createState() => _BarcodeScannerTabState();
}

class _BarcodeScannerTabState extends State<BarcodeScannerTab> {
  bool _isProcessing = false;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return; // Prevent multiple calls
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isProcessing = true;
        });

        // 1. Fetch Data
        final product = await OpenFoodFactsService.fetchProductByBarcode(barcode.rawValue!);

        if (!mounted) return;

        if (product != null) {
          // 2. Navigate to Details Page and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                product: product,
                consumedAt: widget.consumedAt,
                mode: widget.mode,
              ),
            ),
          );

          if (!mounted) return;

          // 3. Check if product was added successfully
          if (result != null && result is Map && result['success'] == true) {
            // Close the ProductSearchPage (the parent of this tab) 
            // and return the result to MealLogScreen
            Navigator.pop(context, result);
            return; 
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product not found for code: ${barcode.rawValue}')),
          );
        }

        // 4. Reset processing state ONLY if we didn't add a product (user cancelled or product not found)
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _handleBarcode,
        ),
        
        // Overlay guide
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Loading Overlay
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Fetching Product Data...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}