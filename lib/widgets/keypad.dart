import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';
import '../screens/daily.dart';
import '../screens/gross.dart';
import '../screens/input.dart';
import '../screens/record.dart';

class Keypad extends StatelessWidget {
  const Keypad({super.key});

  Widget button(
    BuildContext context,
    String text, {

    Color? color,

    Color textColor = Colors.white,

    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),

        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xff37474F),

            foregroundColor: textColor,

            elevation: 5,

            minimumSize: const Size(70, 70),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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

          child: icon != null
              ? Icon(icon, size: 32, color: Colors.white)
              : Text(
                  text,

                  style: TextStyle(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,

                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }

  Widget row(BuildContext context, List<Widget> buttons) {
    return Row(children: buttons);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: const Color(0xff263238),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [BoxShadow(blurRadius: 15, color: Colors.black26)],
      ),

      child: Column(
        children: [
          row(context, [
            button(
              context,

              "AC",

              color: Colors.red.shade700,

              icon: Icons.delete_sweep,
            ),

            button(context, "7"),

            button(context, "8"),

            button(context, "9"),

            button(context, "I", color: Colors.blue.shade700),
          ]),

          row(context, [
            // IMPORTANT:
            // text remains X for operation
            button(
              context,

              "X",

              color: Colors.orange.shade700,

              icon: Icons.backspace,
            ),

            button(context, "4"),

            button(context, "5"),

            button(context, "6"),

            button(context, "G", color: Colors.green.shade700),
          ]),

          row(context, [
            button(
              context,

              "C",

              color: Colors.orange.shade700,

              icon: Icons.clear,
            ),

            button(context, "1"),

            button(context, "2"),

            button(context, "3"),

            button(context, "R", color: Colors.purple.shade700),
          ]),

          row(context, [
            button(context, "0"),

            button(context, "00"),

            button(context, "000"),

            button(
              context,

              "✔",

              color: Colors.green.shade800,

              icon: Icons.check_circle,
            ),

            button(context, "D", color: Colors.teal.shade700),
          ]),
        ],
      ),
    );
  }
}
