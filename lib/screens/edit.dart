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

  Future<void> updateRecord() async {
    int good = int.tryParse(goodController.text) ?? 0;

    int reject = int.tryParse(rejectController.text) ?? 0;

    int qa = int.tryParse(qaController.text) ?? 0;

    int sample = int.tryParse(sampleController.text) ?? 0;

    print("Machine: $machine");
    print("Plant: $plant");
    print("Product: $productCode");

    Production updated = Production(
      id: widget.production.id,

      machine: machine,

      plant: plant,

      productCode: productCode,

      good: good,

      reject: reject,

      qa: qa,

      sample: sample,

      tested: good + reject + qa + sample,
    );

    await DatabaseHelper.instance.updateProduction(updated);

    Navigator.pop(context);
  }

  Widget dropdown(
    String title,
    String value,
    List<String> items,
    Function(String) change,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),

      child: DropdownButtonFormField<String>(
        initialValue: items.contains(value) ? value : items.first,

        decoration: InputDecoration(
          labelText: title,

          border: const OutlineInputBorder(),
        ),

        items: items.map((e) {
          return DropdownMenuItem<String>(value: e, child: Text(e));
        }).toList(),

        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              change(newValue);
            });
          }
        },
      ),
    );
  }

  Widget input(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8),

      child: TextField(
        controller: controller,

        keyboardType: TextInputType.number,

        decoration: InputDecoration(
          labelText: title,

          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Record")),

      body: SingleChildScrollView(
        child: Column(
          children: [
            dropdown("Machine", machine, machines, (v) {
              machine = v;
            }),

            dropdown("Plant", plant, plants, (v) {
              plant = v;
            }),

            dropdown("Product Code", productCode, productCodes, (v) {
              productCode = v;
            }),

            input("Good", goodController),

            input("Reject", rejectController),

            input("QA", qaController),

            input("Sample", sampleController),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateRecord,

              child: const Text("UPDATE"),
            ),
          ],
        ),
      ),
    );
  }
}
