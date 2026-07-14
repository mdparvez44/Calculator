import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';
import '../utils/constants.dart';

class Dropdowns extends StatelessWidget {
  const Dropdowns({super.key});

  Widget dropBox(
    BuildContext context,
    String title,
    String value,
    List<String> items,
    IconData icon,
    Function(String) onChange,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: Colors.black26),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(icon, size: 18),

              const SizedBox(width: 6),

              Text(
                title,

                style: const TextStyle(
                  fontWeight: FontWeight.bold,

                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,

            isExpanded: true,

            decoration: InputDecoration(
              filled: true,

              fillColor: const Color(0xfff5f5f5),

              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,

                vertical: 8,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),

                borderSide: const BorderSide(color: Colors.black26),
              ),
            ),

            style: const TextStyle(
              fontSize: 16,

              fontWeight: FontWeight.bold,

              color: Colors.black,
            ),

            items: items.map((e) {
              return DropdownMenuItem(
                value: e,

                child: Text(
                  e,

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),

            onChanged: (v) {
              if (v != null) {
                onChange(v);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductionProvider>();

    return Container(
      margin: const EdgeInsets.all(10),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xffeceff1),

        borderRadius: BorderRadius.circular(16),

        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),

      child: Row(
        children: [
          // MACHINE
          Expanded(
            flex: 2,

            child: Row(
              children: [
                Expanded(
                  child: dropBox(
                    context,

                    "Machine",

                    p.machine,

                    machines,

                    Icons.precision_manufacturing,

                    (value) {
                      p.changeMachine(value);
                    },
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  height: 70,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: p.nextMachine,

                    child: const Icon(Icons.skip_next, size: 28),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // PLANT
          Expanded(
            child: dropBox(context, "Plant", p.plant, plants, Icons.factory, (
              value,
            ) {
              p.changePlant(value);
            }),
          ),

          const SizedBox(width: 12),

          // PRODUCT CODE
          Expanded(
            child: dropBox(
              context,

              "Product Code",

              p.productCode,

              productCodes,

              Icons.qr_code,

              (value) {
                p.changeProduct(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
