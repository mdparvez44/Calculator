import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';
import '../screens/gross.dart';
import '../screens/input.dart';
import '../screens/daily.dart';
import '../screens/record.dart';

class Keypad extends StatelessWidget {
  const Keypad({super.key});

  Widget button(BuildContext context, String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),

        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,

            padding: const EdgeInsets.all(20),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          onPressed: () async {
            final provider = context.read<ProductionProvider>();

            // Numbers

            if (text == "0" ||
                text == "00" ||
                text == "000" ||
                int.tryParse(text) != null) {
              provider.addNumber(text);
            }
            // Delete last digit
            else if (text == "X") {
              provider.deleteOne();
            }
            // Clear current box
            else if (text == "C") {
              provider.clearCurrent();
            }
            // Clear all
            else if (text == "AC") {
              provider.clearAll();
            }
            // Next field
            else if (text == "✔") {
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

          child: Text(
            text,

            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            button(context, "AC", color: Colors.red),

            button(context, "7"),

            button(context, "8"),

            button(context, "9"),

            button(context, "I"),
          ],
        ),

        Row(
          children: [
            button(context, "X"),

            button(context, "4"),

            button(context, "5"),

            button(context, "6"),

            button(context, "G"),
          ],
        ),

        Row(
          children: [
            button(context, "C"),

            button(context, "1"),

            button(context, "2"),

            button(context, "3"),

            button(context, "R"),
          ],
        ),

        Row(
          children: [
            button(context, "000"),

            button(context, "00"),

            button(context, "0"),

            button(context, "✔", color: Colors.green),

            button(context, "D"),
          ],
        ),
      ],
    );
  }
}
