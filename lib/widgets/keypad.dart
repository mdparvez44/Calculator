import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';
import '../screens/daily.dart';
import '../screens/gross.dart';
import '../screens/input.dart';
import '../screens/record.dart';

class Keypad extends StatelessWidget {
  final double? rowHeight;

  const Keypad({super.key, this.rowHeight});

  Widget button(
    BuildContext context,
    String text,
    double scale, {
    Color? color,
    Color textColor = Colors.white,
    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(3.5 * scale),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xff37474F),
            foregroundColor: textColor,
            elevation: 3,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * scale),
            ),
          ),
          onPressed: () async {
            final provider = context.read<ProductionProvider>();

            if (text == "0" ||
                text == "00" ||
                text == "000" ||
                int.tryParse(text) != null) {
              provider.addNumber(text);
            } else if (text == "X") {
              provider.deleteOne();
            } else if (text == "C") {
              provider.clearCurrent();
            } else if (text == "AC") {
              provider.clearAll();
            } else if (text == "✔") {
              await provider.nextField();
            } else if (text == "G") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GrossScreen()),
              );
            } else if (text == "I") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InputSheet()),
              );
            } else if (text == "D") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyReport()),
              );
            } else if (text == "R") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecordScreen()),
              );
            }
          },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: icon != null
                ? Icon(icon, size: 25 * scale, color: Colors.white)
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget row(BuildContext context, List<Widget> buttons, double scale) {
    double h = rowHeight ?? (52.0 * scale);
    return SizedBox(
      height: h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = (screenWidth / 375).clamp(0.85, 1.25);

    return Container(
      padding: EdgeInsets.all(6 * scale),
      margin: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: const Color(0xff263238),
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          row(context, [
            button(
              context,
              "AC",
              scale,
              color: Colors.red.shade700,
              icon: Icons.delete_sweep,
            ),
            button(context, "7", scale),
            button(context, "8", scale),
            button(context, "9", scale),
            button(context, "I", scale, color: Colors.blue.shade700),
          ], scale),
          row(context, [
            button(
              context,
              "X",
              scale,
              color: Colors.orange.shade700,
              icon: Icons.backspace,
            ),
            button(context, "4", scale),
            button(context, "5", scale),
            button(context, "6", scale),
            button(context, "G", scale, color: Colors.green.shade700),
          ], scale),
          row(context, [
            button(
              context,
              "C",
              scale,
              color: Colors.orange.shade700,
              icon: Icons.clear,
            ),
            button(context, "1", scale),
            button(context, "2", scale),
            button(context, "3", scale),
            button(context, "R", scale, color: Colors.purple.shade700),
          ], scale),
          row(context, [
            button(context, "0", scale),
            button(context, "00", scale),
            button(context, "000", scale),
            button(
              context,
              "✔",
              scale,
              color: Colors.green.shade800,
              icon: Icons.check_circle,
            ),
            button(context, "D", scale, color: Colors.teal.shade700),
          ], scale),
        ],
      ),
    );
  }
}
