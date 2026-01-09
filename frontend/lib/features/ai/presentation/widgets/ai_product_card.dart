import 'package:flutter/material.dart';
import 'package:frontend/features/ai/data/ai_response.dart';

class AiProductCard extends StatefulWidget {
  final List<AIResponse> predictions; // Top 3 predictions
  final VoidCallback onRemove;
  final Function(AIResponse, double) onAccepted;

  const AiProductCard({
    super.key,
    required this.predictions,
    required this.onRemove,
    required this.onAccepted,
  });

  @override
  State<AiProductCard> createState() => _AiProductCardState();
}

class _AiProductCardState extends State<AiProductCard> {
  bool _isExpanded = false;
  AIResponse? _selectedProduct;
  final TextEditingController _weightController = TextEditingController(text: '100');

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPrediction = widget.predictions.first;
    final isAccepted = _selectedProduct != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isAccepted ? Colors.green : Colors.grey[200]!, width: isAccepted ? 2 : 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: _getProbabilityColor(topPrediction.probability),
              child: Text(
                '${(topPrediction.probability * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            title: Text(
              isAccepted ? _selectedProduct!.product.name : topPrediction.product.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              isAccepted
                  ? _selectedProduct!.product.manufacturer ?? 'Unknown'
                  : topPrediction.product.manufacturer ?? 'Unknown',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAccepted && widget.predictions.length > 1)
                  IconButton(
                    icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[700]),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
          ),

          // Expanded alternatives (tylko gdy nie zaakceptowano)
          if (_isExpanded && !isAccepted && widget.predictions.length > 1) _buildAlternatives(),

          // Weight input (gdy zaakceptowano)
          if (isAccepted) _buildWeightInput(),

          // Accept button (gdy nie zaakceptowano)
          if (!isAccepted) _buildAcceptButton(topPrediction),
        ],
      ),
    );
  }

  Widget _buildAlternatives() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other predictions:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          ...widget.predictions.skip(1).map((prediction) => _buildAlternativeItem(prediction)),
        ],
      ),
    );
  }

  Widget _buildAlternativeItem(AIResponse prediction) {
    return InkWell(
      onTap: () => _acceptProduct(prediction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getProbabilityColor(prediction.probability).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(prediction.probability * 100).toInt()}%',
                style: TextStyle(
                  color: _getProbabilityColor(prediction.probability),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.product.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  if (prediction.product.manufacturer != null)
                    Text(
                      prediction.product.manufacturer!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ),
            Icon(Icons.check_circle_outline, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.scale, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (g)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => _updateAcceptedProduct(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: () => setState(() {
              _selectedProduct = null;
              _isExpanded = false;
            }),
            tooltip: 'Change selection',
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton(AIResponse topPrediction) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _acceptProduct(topPrediction),
        icon: const Icon(Icons.check_circle, size: 20),
        label: const Text('Accept'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _acceptProduct(AIResponse product) {
    setState(() {
      _selectedProduct = product;
      _isExpanded = false;
    });
    _updateAcceptedProduct();
  }

  void _updateAcceptedProduct() {
    if (_selectedProduct != null) {
      final weight = double.tryParse(_weightController.text) ?? 100.0;
      widget.onAccepted(_selectedProduct!, weight);
    }
  }

  Color _getProbabilityColor(double probability) {
    if (probability > 0.7) return Colors.green;
    if (probability > 0.4) return Colors.orange;
    return Colors.red;
  }
}
