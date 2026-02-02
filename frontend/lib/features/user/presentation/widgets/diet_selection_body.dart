import 'package:flutter/material.dart';

class DietSelectionBody extends StatefulWidget {
  final Function(String name, Map<String, int>) onDataChanged;
  final String? initialDietType;
  final Map<String, int>? initialMacroSplit;

  const DietSelectionBody({
    super.key,
    required this.onDataChanged,
    this.initialDietType,
    this.initialMacroSplit,
  });

  @override
  State<DietSelectionBody> createState() => _DietSelectionBodyState();
}

class _DietSelectionBodyState extends State<DietSelectionBody> {
  String? _selectedDietType;
  List<String> _touchHistory = ["Carbs", "Protein", "Fat"];
  Map<String, double> _macroSplit = {"Carbs": 40, "Protein": 30, "Fat": 30};

  // Pamięć dla ustawień Custom
  Map<String, double> _customMacroSplit = {"Carbs": 40, "Protein": 30, "Fat": 30};

  @override
  void initState() {
    super.initState();

    // Domyślnie "balanced" jeśli nic nie przekazano (szczególnie w onboarding)
    _selectedDietType = widget.initialDietType?.toLowerCase() ?? "balanced";

    if (widget.initialMacroSplit != null) {
      _macroSplit = widget.initialMacroSplit!.map((k, v) => MapEntry(k, v.toDouble()));
      if (_selectedDietType == "custom") {
        _customMacroSplit = Map.from(_macroSplit);
      }
    } else {
      // Wartości domyślne dla Balanced
      _macroSplit = {"Carbs": 40, "Protein": 30, "Fat": 30};
    }
  }

  void _updateDiet(String type, Map<String, double> split) {
    setState(() {
      _selectedDietType = type;
      if (type == 'custom') {
        _macroSplit = Map.from(_customMacroSplit);
      } else {
        _macroSplit = Map.from(split);
      }
    });
    _notify();
  }

  void _notify() {
    final finalMap = _macroSplit.map((k, v) => MapEntry(k, v.round()));
    widget.onDataChanged(_selectedDietType!.toUpperCase(), finalMap);
  }

  void _onSliderChanged(String currentKey, double newValue) {
    setState(() {
      _selectedDietType = 'custom';

      // Minimalna wartość 1%
      if (newValue < 1) newValue = 1;
      if (newValue > 98) newValue = 98;

      _touchHistory.remove(currentKey);
      _touchHistory.insert(0, currentKey);

      double oldValue = _macroSplit[currentKey]!;
      double delta = newValue - oldValue;

      String primaryTargetKey = _touchHistory.last;
      String secondaryTargetKey = _touchHistory[1];

      double primaryValue = _macroSplit[primaryTargetKey]!;
      double secondaryValue = _macroSplit[secondaryTargetKey]!;
      double remainingDelta = delta;

      if (delta > 0) {
        double availableFromPrimary = primaryValue - 1;
        double takeFromPrimary = remainingDelta > availableFromPrimary
            ? availableFromPrimary
            : remainingDelta;
        _macroSplit[primaryTargetKey] = primaryValue - takeFromPrimary;
        remainingDelta -= takeFromPrimary;

        if (remainingDelta > 0) {
          double availableFromSecondary = secondaryValue - 1;
          double takeFromSecondary = remainingDelta > availableFromSecondary
              ? availableFromSecondary
              : remainingDelta;
          _macroSplit[secondaryTargetKey] = secondaryValue - takeFromSecondary;
          remainingDelta -= takeFromSecondary;
        }
      } else {
        double canAddPrimary = 100 - primaryValue;
        double addToPrimary = (-remainingDelta) > canAddPrimary ? canAddPrimary : -remainingDelta;
        _macroSplit[primaryTargetKey] = primaryValue + addToPrimary;
        remainingDelta += addToPrimary;

        if (remainingDelta < 0) {
          double canAddSecondary = 100 - secondaryValue;
          double addToSecondary = (-remainingDelta) > canAddSecondary ? canAddSecondary : -remainingDelta;
          _macroSplit[secondaryTargetKey] = secondaryValue + addToSecondary;
          remainingDelta += addToSecondary;
        }
      }

      _macroSplit[currentKey] = newValue;

      double total = _macroSplit.values.reduce((a, b) => a + b);
      if ((100 - total).abs() > 0.01) {
        _macroSplit[primaryTargetKey] = (_macroSplit[primaryTargetKey]! + (100 - total)).clamp(1, 98);
      }

      _customMacroSplit = Map.from(_macroSplit);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'What is your diet type?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  _dietOption('Balanced', 'Optimal balance for health', 'balanced', {
                    "Carbs": 40,
                    "Protein": 30,
                    "Fat": 30,
                  }),
                  const SizedBox(height: 10),
                  _dietOption('Low Carb', 'Higher fats & protein', 'low_carb', {
                    "Carbs": 10,
                    "Protein": 30,
                    "Fat": 60,
                  }),
                  const SizedBox(height: 10),
                  _dietOption('Low Fat', 'Higher carbs & protein', 'low_fat', {
                    "Carbs": 60,
                    "Protein": 30,
                    "Fat": 10,
                  }),
                  const SizedBox(height: 10),
                  _dietOption('Custom', 'Set your own macros', 'custom', _macroSplit),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _macroRow('Carbs', Colors.green),
                        const SizedBox(height: 12),
                        _macroRow('Protein', Colors.redAccent),
                        const SizedBox(height: 12),
                        _macroRow('Fat', Colors.orange),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dietOption(String title, String desc, String type, Map<String, double> split) {
    bool isSelected = _selectedDietType == type;
    return InkWell(
      onTap: () => _updateDiet(type, split),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: isSelected ? 100 : 70,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF0F465D) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? const Color(0xFF0F465D).withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  if (isSelected) Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF0F465D)),
          ],
        ),
      ),
    );
  }

  Widget _macroRow(String key, Color color) {
    double value = _macroSplit[key]!;
    bool isCustom = _selectedDietType == 'custom';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Text('${value.round()}%', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            trackShape: FullWidthTrackShape(),
            overlayShape: isCustom
                ? const RoundSliderOverlayShape(overlayRadius: 8)
                : SliderComponentShape.noOverlay,
            thumbShape: isCustom
                ? const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 2)
                : SliderComponentShape.noThumb,
            disabledActiveTrackColor: color,
            disabledInactiveTrackColor: color.withOpacity(0.2),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 32,
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              activeColor: color,
              inactiveColor: color.withOpacity(0.2),
              onChanged: isCustom ? (val) => _onSliderChanged(key, val) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class FullWidthTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
