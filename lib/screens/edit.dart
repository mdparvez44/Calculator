import 'package:flutter/material.dart';

import '../database/database.dart';
import '../models/production.dart';
import '../utils/constants.dart';

class EditRecord extends StatefulWidget {
  final Production production;

  const EditRecord({super.key, required this.production});

  @override
  State<EditRecord> createState() => _EditRecordState();
}

class _EditRecordState extends State<EditRecord> {
  late String machine;

  late String plant;

  late String productCode;

  late TextEditingController goodController;

  late TextEditingController rejectController;

  late TextEditingController qaController;

  late TextEditingController sampleController;

  @override
  void initState() {
    super.initState();

    machine = widget.production.machine;

    plant = widget.production.plant;

    productCode = widget.production.productCode;

    goodController = TextEditingController(
      text: widget.production.good.toString(),
    );

    rejectController = TextEditingController(
      text: widget.production.reject.toString(),
    );

    qaController = TextEditingController(text: widget.production.qa.toString());

    sampleController = TextEditingController(
      text: widget.production.sample.toString(),
    );
  }

  int get tested {
    int good = int.tryParse(goodController.text) ?? 0;

    int reject = int.tryParse(rejectController.text) ?? 0;

    int qa = int.tryParse(qaController.text) ?? 0;

    return good + reject + qa;
  }

  Future<void> updateRecord() async {
    int good = int.tryParse(goodController.text) ?? 0;

    int reject = int.tryParse(rejectController.text) ?? 0;

    int qa = int.tryParse(qaController.text) ?? 0;

    int sample = int.tryParse(sampleController.text) ?? 0;

    Production updated = Production(
      id: widget.production.id,

      machine: machine,

      plant: plant,

      productCode: productCode,

      good: good,

      reject: reject,

      qa: qa,

      sample: sample,

      // sample not included
      tested: good + reject + qa,
    );

    await DatabaseHelper.instance.updateProduction(updated);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget dropdown(
    String title,
    String value,
    List<String> items,
    Function(String) change,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),

      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : items.first,

        decoration: InputDecoration(
          labelText: title,

          prefixIcon: Icon(icon),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        items: items.map((e) {
          return DropdownMenuItem(
            value: e,

            child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),

        onChanged: (v) {
          if (v != null) {
            setState(() {
              change(v);
            });
          }
        },
      ),
    );
  }

  Widget input(
    String title,
    TextEditingController controller,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),

      child: TextField(
        controller: controller,

        keyboardType: TextInputType.number,

        onChanged: (v) {
          setState(() {});
        },

        decoration: InputDecoration(
          labelText: title,

          prefixIcon: Icon(icon, color: color),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),

      appBar: AppBar(title: const Text("Edit Production Record")),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Record Details",

                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                dropdown("Machine", machine, machines, (v) {
                  machine = v;
                }, Icons.precision_manufacturing),

                dropdown("Plant", plant, plants, (v) {
                  plant = v;
                }, Icons.factory),

                dropdown("Product Code", productCode, productCodes, (v) {
                  productCode = v;
                }, Icons.qr_code),

                const Divider(height: 30),

                input("Good", goodController, Icons.check_circle, Colors.green),

                input("Reject", rejectController, Icons.cancel, Colors.red),

                input("Q.C", qaController, Icons.science, Colors.blue),

                input(
                  "Sample",
                  sampleController,
                  Icons.inventory,
                  Colors.orange,
                ),

                Container(
                  margin: const EdgeInsets.only(top: 15),

                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Tested",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text(
                        tested.toString(),

                        style: const TextStyle(
                          fontSize: 22,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),

                    label: const Text(
                      "UPDATE RECORD",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    onPressed: updateRecord,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
