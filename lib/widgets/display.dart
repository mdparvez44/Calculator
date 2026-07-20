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
    VoidCallback onTap,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = (screenWidth / 375).clamp(0.8, 1.25);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(3.5 * scale),
          padding: EdgeInsets.all(7 * scale),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.18) : Colors.white,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: active ? color : Colors.black26,
              width: active ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: active ? 6 : 3,
                color: active ? color.withValues(alpha: 0.2) : Colors.black12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16 * scale, color: color),
                    SizedBox(width: 3.5 * scale),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5 * scale,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6 * scale),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6 * scale, horizontal: 3 * scale),
                decoration: BoxDecoration(
                  color: active ? Colors.white : const Color(0xfff5f5f5),
                  borderRadius: BorderRadius.circular(8 * scale),
                  border: active ? Border.all(color: color.withValues(alpha: 0.3)) : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value.isEmpty ? "0" : value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23 * scale,
                      fontWeight: FontWeight.bold,
                      color: active ? color : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductionProvider>();
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = (screenWidth / 375).clamp(0.8, 1.25);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xffeceff1),
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
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
            () => p.selectField(0),
          ),
          buildBox(
            context,
            "REJECT",
            p.reject,
            p.currentField == 1,
            Icons.cancel,
            Colors.red,
            () => p.selectField(1),
          ),
          buildBox(
            context,
            "Q.C",
            p.qa,
            p.currentField == 2,
            Icons.science,
            Colors.blue,
            () => p.selectField(2),
          ),
          buildBox(
            context,
            "SAMPLE",
            p.sample,
            p.currentField == 3,
            Icons.inventory,
            Colors.orange,
            () => p.selectField(3),
          ),
        ],
      ),
    );
  }
}
