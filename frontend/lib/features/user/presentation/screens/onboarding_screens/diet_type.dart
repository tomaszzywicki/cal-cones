import 'package:flutter/material.dart';

class DietType extends StatefulWidget {
  const DietType({super.key});

  @override
  State<DietType> createState() => _DietTypeState();
}

class _DietTypeState extends State<DietType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDietTypeCard('Standard', 'Balanced distribution of carbs protein and fat', Icons.balance),
            _buildDietTypeCard('Cośtam', 'Lorep ipsum', Icons.texture),
            _buildDietTypeCard('Cośtam', 'Ipsum lorem', Icons.texture),
          ],
        ),
      ),
    );
  }
}

Widget _buildDietTypeCard(String title, String text, IconData icon) {
  return Container(
    // decoration:
    child: ListTile(title: Text(title), subtitle: Text(text), trailing: Icon(icon)),
  );
}
