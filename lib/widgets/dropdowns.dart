import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';
import '../utils/constants.dart';

class Dropdowns extends StatelessWidget {
  const Dropdowns({super.key});

  Widget dropBox(
    String title,
    String value,
    List<String> items,
    Function(String) onChange,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,

            isExpanded: true,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),

              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),

            items: items
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),

            onChanged: (v) {
              if (v != null) {
                onChange(v);
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductionProvider>();

    return Container(
      padding: const EdgeInsets.all(12),

      child: Row(
        children: [
          // ================= MACHINE =================
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: dropBox("M", p.machine, machines, (value) {
                    p.changeMachine(value);
                  }),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      p.nextMachine();
                    },

                    child: const Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ================= PLANT =================
          Expanded(
            child: dropBox("P", p.plant, plants, (value) {
              p.changePlant(value);
            }),
          ),

          const SizedBox(width: 12),

          // ================= PRODUCT CODE =================
          Expanded(
            child: dropBox("CD", p.productCode, productCodes, (value) {
              p.changeProduct(value);
            }),
          ),
        ],
      ),
    );
  }
}
