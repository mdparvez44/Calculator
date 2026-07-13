import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider.dart';

class Display extends StatelessWidget {
  const Display({super.key});

  Widget buildBox(String title, String value, bool active) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: active ? Colors.amber.shade200 : Colors.white,

          border: Border.all(width: 2),

          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Text(
              value.isEmpty ? "0" : value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductionProvider>();

    return Row(
      children: [
        buildBox("GP", p.good, p.currentField == 0),

        buildBox("RP", p.reject, p.currentField == 1),

        buildBox("Qty", p.qa, p.currentField == 2),

        buildBox("Sample", p.sample, p.currentField == 3),
      ],
    );
  }
}
