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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double calculatedRowHeight = (constraints.maxHeight < 600)
                ? (constraints.maxHeight * 0.072)
                : (constraints.maxHeight * 0.11).clamp(40.0, 95.0);

            return Column(
              children: [
                const Dropdowns(),
                const Display(),
                const Spacer(),
                Keypad(rowHeight: calculatedRowHeight),
              ],
            );
          },
        ),
      ),
    );
  }
}
