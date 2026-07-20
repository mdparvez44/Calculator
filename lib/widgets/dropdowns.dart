import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/provider.dart';
import '../utils/constants.dart';

class Dropdowns extends StatelessWidget {
  const Dropdowns({super.key});

  void _showGridDialog(
    BuildContext context,
    String title,
    String currentValue,
    List<String> items,
    Function(String) onChange,
    double scale,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double dialogWidth = constraints.maxWidth;
            int crossAxisCount = dialogWidth > 600 ? 5 : (dialogWidth > 400 ? 4 : 3);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * scale),
              ),
              title: Text(
                "Select $title",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18 * scale),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 8 * scale,
                    mainAxisSpacing: 8 * scale,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    String item = items[index];
                    bool isSelected = item == currentValue;

                    return InkWell(
                      onTap: () {
                        onChange(item);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(8 * scale),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blueGrey
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8 * scale),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueGrey.shade700
                                : Colors.black12,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                            child: Text(
                              item,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13 * scale,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget dropBox(
    BuildContext context,
    String title,
    String value,
    List<String> items,
    IconData icon,
    Function(String) onChange,
    double scale,
  ) {
    // FIX: If the value is empty, show "Select". Otherwise, show the chosen value.
    String displayValue = (value.trim().isEmpty) ? "Select" : value;

    return Container(
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Row(
              children: [
                Icon(icon, size: 16 * scale),
                SizedBox(width: 4 * scale),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12 * scale,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5 * scale),
          InkWell(
            onTap: () =>
                _showGridDialog(context, title, value, items, onChange, scale),
            borderRadius: BorderRadius.circular(8 * scale),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 10 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xfff5f5f5),
                borderRadius: BorderRadius.circular(8 * scale),
                border: Border.all(color: Colors.black26),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayValue,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.bold,
                          color: displayValue == "Select"
                              ? Colors.black54
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18 * scale,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductionProvider>();
    double screenWidth = MediaQuery.of(context).size.width;
    double scale = (screenWidth / 375).clamp(0.8, 1.25);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 4 * scale),
      padding: EdgeInsets.all(5 * scale),
      decoration: BoxDecoration(
        color: const Color(0xffeceff1),
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    child: dropBox(
                      context,
                      "Machine",
                      p.machine,
                      machines,
                      Icons.precision_manufacturing,
                      (value) => p.changeMachine(value),
                      scale,
                    ),
                  ),
                  SizedBox(width: 3 * scale),
                  Tooltip(
                    message: "Next Machine",
                    child: SizedBox(
                      width: 38 * scale,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.blueGrey.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                        ),
                        onPressed: p.nextMachine,
                        child: Icon(Icons.skip_next, size: 20 * scale),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4 * scale),
            Expanded(
              flex: 3,
              child: dropBox(
                context,
                "Plant",
                p.plant,
                plants,
                Icons.factory,
                (value) => p.changePlant(value),
                scale,
              ),
            ),
            SizedBox(width: 4 * scale),
            Expanded(
              flex: 5,
              child: dropBox(
                context,
                "Product Code",
                p.productCode,
                productCodes,
                Icons.qr_code,
                (value) => p.changeProduct(value),
                scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

