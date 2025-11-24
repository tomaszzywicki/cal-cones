import 'package:flutter/material.dart';
import 'package:frontend/features/temp/presentation/screens/user_info.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 50),
        child: Column(
          children: [
            Text('Other page here'),
            SizedBox(height: 20),
            SizedBox(child: UserInfo(), height: 300),
          ],
        ),
      ),
    );
  }
}
