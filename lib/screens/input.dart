import 'package:flutter/material.dart';

import '../database/database.dart';
import '../models/production.dart';
import 'edit.dart';

class InputSheet extends StatefulWidget {
  const InputSheet({super.key});

  @override
  State<InputSheet> createState() => _InputSheetState();
}

class _InputSheetState extends State<InputSheet> {
  List<Production> records = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    final data = await DatabaseHelper.instance.getAllProductions();

    setState(() {
      records = data;
    });
  }

  Future<void> deleteRecord(int id) async {
    await DatabaseHelper.instance.deleteProduction(id);

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Production Sheet")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  "Total Records : ${records.length}",

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,

                    foregroundColor: Colors.white,
                  ),

                  icon: const Icon(Icons.delete_forever),

                  label: const Text("Delete Table"),

                  onPressed: () async {
                    bool? confirm = await showDialog<bool>(
                      context: context,

                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete All Data?"),

                          content: const Text(
                            "This will remove all production records permanently.",
                          ),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },

                              child: const Text("Cancel"),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),

                              onPressed: () {
                                Navigator.pop(context, true);
                              },

                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      await DatabaseHelper.instance.deleteAllProductions();

                      loadData();
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: records.isEmpty
                ? const Center(child: Text("No Records"))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: DataTable(
                      columnSpacing: 30,

                      border: TableBorder.all(),

                      columns: const [
                        DataColumn(label: Text("No")),

                        DataColumn(label: Text("M.No")),

                        DataColumn(label: Text("P.Code")),

                        DataColumn(label: Text("Plant")),

                        DataColumn(label: Text("Tested")),

                        DataColumn(label: Text("Good")),

                        DataColumn(label: Text("Reject")),

                        DataColumn(label: Text("QA")),

                        DataColumn(label: Text("Sample")),

                        DataColumn(label: Text("")),
                      ],

                      rows: records.asMap().entries.map((entry) {
                        int index = entry.key;

                        Production item = entry.value;

                        return DataRow(
                          onSelectChanged: (value) {
                            if (value == true) {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) => EditRecord(production: item),
                                ),
                              ).then((_) {
                                loadData();
                              });
                            }
                          },

                          cells: [
                            DataCell(Text("${index + 1}")),

                            DataCell(Text(item.machine)),

                            DataCell(Text(item.productCode)),

                            DataCell(Text(item.plant)),

                            DataCell(Text(item.tested.toString())),

                            DataCell(Text(item.good.toString())),

                            DataCell(Text(item.reject.toString())),

                            DataCell(Text(item.qa.toString())),

                            DataCell(Text(item.sample.toString())),

                            DataCell(
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),

                                onPressed: () {
                                  deleteRecord(item.id!);
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
