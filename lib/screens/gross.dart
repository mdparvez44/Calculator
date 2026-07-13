import 'package:flutter/material.dart';

import '../database/database.dart';

class GrossScreen extends StatefulWidget {
  const GrossScreen({super.key});

  @override
  State<GrossScreen> createState() => _GrossScreenState();
}

class _GrossScreenState extends State<GrossScreen> {
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    loadGross();
  }

  Future<void> loadGross() async {
    final result = await DatabaseHelper.instance.getMachineGross();

    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Machine Gross")),

      body: data.isEmpty
          ? const Center(child: Text("No Data", style: TextStyle(fontSize: 20)))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: DataTable(
                border: TableBorder.all(),

                columnSpacing: 40,

                columns: const [
                  DataColumn(
                    label: Text(
                      "Machine",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      "Tested",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  DataColumn(
                    label: Text(
                      "Gross",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],

                rows: data.map((item) {
                  int tested = item["totalTested"] ?? 0;

                  double gross = tested / 144;

                  return DataRow(
                    cells: [
                      DataCell(Text(item["machine"].toString())),

                      DataCell(Text(tested.toString())),

                      DataCell(
                        Text(
                          gross.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
