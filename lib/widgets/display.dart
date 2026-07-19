import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';

class Display extends StatelessWidget {
  const Display({super.key});

  Widget buildBox(
    BuildContext context,
    String title,
    String value,
    bool active,
    IconData icon,
    Color color,
  ) {
    // Responsive scaling factor based on screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / 375; // 375 is a standard mobile base width

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(4 * scale),
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.25) : Colors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: active ? color : Colors.black26,
            width: active ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            FittedBox(
              // Ensures text doesn't overflow
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14 * scale, color: color),
                  SizedBox(width: 4 * scale),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6 * scale),
              decoration: BoxDecoration(
                color: active ? Colors.white : const Color(0xfff5f5f5),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.isEmpty ? "0" : value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.bold,
                  ),
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
    double scale = MediaQuery.of(context).size.width / 375;

    return Container(
      margin: EdgeInsets.all(8 * scale),
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xffeceff1),
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
      ),
      child: Row(
        children: [
          buildBox(
            context,
            "GOOD",
            p.good,
            p.currentField == 0,
            Icons.check_circle,
            Colors.green,
          ),
          buildBox(
            context,
            "REJECT",
            p.reject,
            p.currentField == 1,
            Icons.cancel,
            Colors.red,
          ),
          buildBox(
            context,
            "Q.C",
            p.qa,
            p.currentField == 2,
            Icons.science,
            Colors.blue,
          ),
          buildBox(
            context,
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
