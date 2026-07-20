import 'package:flutter/material.dart';

import '../widgets/dropdowns.dart';
import '../widgets/display.dart';
import '../widgets/keypad.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const SafeArea(
        child: Column(
          children: [
            Dropdowns(),
            Display(),
            Spacer(),
            Keypad(),
          ],
        ),
      ),
    );
  }
}
