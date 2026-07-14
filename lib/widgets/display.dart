import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';

class Display extends StatelessWidget {
  const Display({super.key});

  Widget buildBox(
    String title,
    String value,
    bool active,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        margin: const EdgeInsets.all(6),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.25) : Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: active ? color : Colors.black26,

            width: active ? 3 : 1,
          ),

          boxShadow: [
            BoxShadow(
              blurRadius: 8,

              color: Colors.black12,

              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Icon(icon, size: 20, color: color),

                const SizedBox(width: 6),

                Text(
                  title,

                  style: TextStyle(
                    fontSize: 15,

                    fontWeight: FontWeight.bold,

                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(vertical: 10),

              decoration: BoxDecoration(
                color: active ? Colors.white : const Color(0xfff5f5f5),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                value.isEmpty ? "0" : value,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 32,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductionProvider>();

    return Container(
      margin: const EdgeInsets.all(10),

      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: const Color(0xffeceff1),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),

      child: Row(
        children: [
          buildBox(
            "GOOD",

            p.good,

            p.currentField == 0,

            Icons.check_circle,

            Colors.green,
          ),

          buildBox(
            "REJECT",

            p.reject,

            p.currentField == 1,

            Icons.cancel,

            Colors.red,
          ),

          buildBox("QA", p.qa, p.currentField == 2, Icons.science, Colors.blue),

          buildBox(
            "SAMPLE",

            p.sample,

            p.currentField == 3,

            Icons.inventory,

            Colors.orange,
          ),
        ],
      ),
    );
  }
}
