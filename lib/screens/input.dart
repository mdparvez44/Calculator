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

  Future<void> deleteAll() async {
    bool? confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Delete All Records?"),

          content: const Text(
            "All production data will be removed permanently.",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

              onPressed: () {
                Navigator.pop(context, true);
              },

              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteAllProductions();

      loadData();
    }
  }

  Widget headerCell(String text) {
    return Container(
      alignment: Alignment.center,

      padding: const EdgeInsets.all(8),

      child: Text(
        text,

        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),

      appBar: AppBar(
        title: const Text("Production Input Sheet"),

        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadData),
        ],
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8),

            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.white,

              border: Border.all(color: Colors.black26),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  "TOTAL RECORDS : ${records.length}",

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

                  label: const Text("Delete"),

                  onPressed: deleteAll,
                ),
              ],
            ),
          ),

          Expanded(
            child: records.isEmpty
                ? const Center(child: Text("No Production Records"))
                : Container(
                    margin: const EdgeInsets.all(8),

                    color: Colors.white,

                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xffdddddd),
                          ),

                          dataRowHeight: 42,

                          headingRowHeight: 45,

                          columnSpacing: 28,

                          border: TableBorder.all(color: Colors.black54),

                          columns: [
                            DataColumn(label: headerCell("No")),

                            DataColumn(label: headerCell("Machine")),

                            DataColumn(label: headerCell("Product")),

                            DataColumn(label: headerCell("Plant")),

                            DataColumn(label: headerCell("Tested")),

                            DataColumn(label: headerCell("Good")),

                            DataColumn(label: headerCell("Reject")),

                            DataColumn(label: headerCell("QA")),

                            DataColumn(label: headerCell("Sample")),

                            DataColumn(label: headerCell("")),
                          ],

                          rows: records.asMap().entries.map((entry) {
                            int index = entry.key;

                            Production item = entry.value;

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                if (index % 2 == 0) {
                                  return const Color(0xfffafafa);
                                }

                                return null;
                              }),

                              onSelectChanged: (value) {
                                if (value == true) {
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditRecord(production: item),
                                    ),
                                  ).then((_) {
                                    loadData();
                                  });
                                }
                              },

                              cells: [
                                DataCell(Center(child: Text("${index + 1}"))),

                                DataCell(Text(item.machine)),

                                DataCell(Text(item.productCode)),

                                DataCell(Text(item.plant)),

                                DataCell(
                                  Text(
                                    (item.good + item.reject + item.qa)
                                        .toString(),
                                  ),
                                ),

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
                  ),
          ),
        ],
      ),
    );
  }
}
