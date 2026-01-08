import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/weight_log/services/weight_log_service.dart';
import 'package:provider/provider.dart';

class BMIcard extends StatelessWidget {
  const BMIcard({super.key});

  _calculateBMI(double weight, int heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<CurrentUserService>().currentUser;
    final weightLogService = context.watch<WeightLogService>();

    return Card(
      child: SizedBox(
        width: double.infinity,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Your BMI", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                user != null && user.height != null && weightLogService.latestEntry != null
                    ? _calculateBMI(weightLogService.latestEntry!.weight, user.height!).toStringAsFixed(1)
                    : 'N/A',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xff44638b),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
