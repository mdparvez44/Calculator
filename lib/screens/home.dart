import 'package:flutter/material.dart';

import '../widgets/dropdowns.dart';
import '../widgets/display.dart';
import '../widgets/keypad.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ET"), centerTitle: true),

      body: Column(
        children: [
          const Dropdowns(),

          const Display(),

          const Spacer(),

          const Keypad(),
        ],
      ),
    );
  }
}
