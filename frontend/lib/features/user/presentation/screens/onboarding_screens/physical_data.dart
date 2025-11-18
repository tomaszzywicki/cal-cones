import 'package:flutter/material.dart';

class PhysicalData extends StatefulWidget {
  const PhysicalData({super.key});

  @override
  State<PhysicalData> createState() => _PhysicalDataState();
}

class _PhysicalDataState extends State<PhysicalData> {
  int _height = 0;
  double _weight = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(label: Text('Height')),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(label: Text("Weight")),
            ),
          ],
        ),
      ),
    );
  }
}
