import 'package:flutter/material.dart';
import 'package:frontend/features/ai/data/ai_response.dart';

class AiProductCard extends StatefulWidget {
  final AIResponse item;
  final VoidCallback onRemove;
  final Function(double weight) onAccepted;
  const AiProductCard({super.key, required this.item, required this.onRemove, required this.onAccepted});

  @override
  State<AiProductCard> createState() => _AiProductCardState();
}

class _AiProductCardState extends State<AiProductCard> {
  bool _isAccepted = false;
  double _weight = 100.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // --- LEWA STRONA: Nazwa i Pstwo ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getProbabilityColor(widget.item.probability).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(widget.item.probability * 100).toStringAsFixed(0)}% confidence',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getProbabilityColor(widget.item.probability),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // --- PRAWA STRONA: Przyciski LUB Waga ---
          if (_isAccepted) _buildWeightContainer() else _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Przycisk Tick
        InkWell(
          onTap: () {
            setState(() {
              _isAccepted = true;
            });
            widget.onAccepted(_weight);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Icon(Icons.check, color: Colors.green[700], size: 20),
          ),
        ),
        const SizedBox(width: 12),
        // Przycisk X
        InkWell(
          onTap: widget.onRemove,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Icon(Icons.close, color: Colors.red[700], size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightContainer() {
    return GestureDetector(
      onTap: _showEditWeightDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Text(
              '${_weight.toStringAsFixed(0)}g',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Alert Box do edycji wagi
  Future<void> _showEditWeightDialog() async {
    final controller = TextEditingController(text: _weight.toStringAsFixed(0));

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'g', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              final newWeight = double.tryParse(controller.text);
              if (newWeight != null && newWeight > 0) {
                setState(() {
                  _weight = newWeight;
                });
                widget.onAccepted(_weight);
                Navigator.pop(context);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Color _getProbabilityColor(double prob) {
    if (prob > 0.8) return Colors.green[700]!;
    if (prob > 0.5) return Colors.orange[700]!;
    return Colors.red[700]!;
  }
}
