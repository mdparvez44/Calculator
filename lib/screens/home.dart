import 'package:flutter/material.dart';

import '../widgets/dropdowns.dart';
import '../widgets/display.dart';
import '../widgets/keypad.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = (screenWidth / 375).clamp(0.8, 1.25);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ET",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Dropdowns(),
            const Display(),
            SizedBox(height: 6 * scale),
            const Expanded(
              child: Keypad(),
            ),
          ],
        ),
      ),
    );
  }
}
