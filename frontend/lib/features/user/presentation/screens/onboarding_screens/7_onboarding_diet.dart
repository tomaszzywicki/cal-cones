import 'package:flutter/material.dart';
import 'package:frontend/features/user/presentation/widgets/onboarding_button.dart';

class OnboardingDiet extends StatefulWidget {
  final Function(String name, Map<String, int>) setDietAndMacro;
  final String? initialDietType;
  final Map<String, int>? initialMacroSplit;

  const OnboardingDiet({
    super.key,
    required this.setDietAndMacro,
    this.initialDietType,
    this.initialMacroSplit,
  });

  @override
  State<OnboardingDiet> createState() => _OnboardingDietState();
}

class _OnboardingDietState extends State<OnboardingDiet> {
  String? _selectedDietType;

  // Przechowujemy kolejność dotykanych suwaków
  List<String> _touchHistory = ["Carbs", "Protein", "Fat"];

  Map<String, double> _macroSplit = {"Carbs": 40, "Protein": 30, "Fat": 30};

  @override
  void initState() {
    super.initState();
    if (widget.initialDietType != null) {
      _selectedDietType = widget.initialDietType!.toLowerCase();
      if (widget.initialMacroSplit != null) {
        _macroSplit = widget.initialMacroSplit!.map((k, v) => MapEntry(k, v.toDouble()));
      }
    }
  }

  void _updateDiet(String type, Map<String, double> split) {
    setState(() {
      _selectedDietType = type;
      _macroSplit = Map.from(split);
    });
  }

  void _onSliderChanged(String currentKey, double newValue) {
    setState(() {
      _selectedDietType = 'custom';

      // Aktualizujemy historię - przesuwamy obecny klucz na początek
      _touchHistory.remove(currentKey);
      _touchHistory.insert(0, currentKey);

      double oldValue = _macroSplit[currentKey]!;
      double delta = newValue - oldValue;

      // Klucz, który chcemy zmienić (ten, którego dotykaliśmy najdawniej)
      String targetKey = _touchHistory.last;
      // Klucz "przypięty" (ten, którego dotykaliśmy tuż przed obecnym)
      String pinnedKey = _touchHistory[1];

      double targetValue = _macroSplit[targetKey]!;

      // Sprawdzamy, ile faktycznie możemy zabrać/dodać do targetu
      double allowedDelta;
      if (delta > 0) {
        allowedDelta = delta > targetValue ? targetValue : delta;
      } else {
        double canAdd = 100 - targetValue;
        allowedDelta = (-delta) > canAdd ? -canAdd : delta;
      }

      // Aktualizujemy wartości
      _macroSplit[currentKey] = oldValue + allowedDelta;
      _macroSplit[targetKey] = targetValue - allowedDelta;

      // Korekta sumy (zaokrąglenia double)
      double total = _macroSplit.values.reduce((a, b) => a + b);
      if ((100 - total).abs() > 0.01) {
        _macroSplit[targetKey] = (_macroSplit[targetKey]! + (100 - total)).clamp(0, 100);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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

            // Panel wizualizacji
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

            const SizedBox(height: 20),
            OnboardingButton(
              text: 'Next',
              onPressed: _selectedDietType == null
                  ? () {}
                  : () {
                      final finalMap = _macroSplit.map((k, v) => MapEntry(k, v.round()));
                      widget.setDietAndMacro(_selectedDietType!.toUpperCase(), finalMap);
                    },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
            // Używamy RoundedRectSliderTrackShape, ale dodajemy marginesy w kontenerze nadrzędnym
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
            height: 32, // Stała wysokość zapobiega "ściskaniu" karty w pionie
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
