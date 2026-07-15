import 'package:flutter/material.dart';

import '../database/database.dart';

class GrossScreen extends StatefulWidget {
  const GrossScreen({super.key});

  @override
  State<GrossScreen> createState() => _GrossScreenState();
}

class _GrossScreenState extends State<GrossScreen> {
  List<Map<String, dynamic>> data = [];

  int totalTested = 0;

  double totalGross = 0;

  // Truncate to 2 decimal places (NO rounding)
  double truncateTo2(double value) {
    return (value * 100).truncate() / 100;
  }

  @override
  void initState() {
    super.initState();

    loadGross();
  }

  Future<void> loadGross() async {
    final result = await DatabaseHelper.instance.getMachineGross();

    int tested = 0;

    for (var item in result) {
      tested += (item["totalTested"] ?? 0) as int;
    }

    setState(() {
      data = result;

      totalTested = tested;

      totalGross = truncateTo2(tested / 144);
    });
  }

  Widget summaryBox(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 13)),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget header(String text) {
    return Padding(
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
        title: const Text("Machine Gross Sheet"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadGross),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            child: Row(
              children: [
                summaryBox(
                  "Machines",
                  data.length.toString(),
                  Icons.precision_manufacturing,
                ),
                summaryBox(
                  "Tested",
                  totalTested.toString(),
                  Icons.check_circle,
                ),
                summaryBox(
                  "Gross",
                  totalGross.toStringAsFixed(2),
                  Icons.analytics,
                ),
              ],
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? const Center(
                    child: Text(
                      "No Production Data",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 50,
                          dataRowHeight: 45,
                          columnSpacing: 45,
                          border: TableBorder.all(color: Colors.black45),
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xffdddddd),
                          ),
                          columns: [
                            DataColumn(label: header("Machine")),
                            DataColumn(label: header("Tested")),
                            DataColumn(label: header("Gross")),
                          ],
                          rows: data.asMap().entries.map((entry) {
                            int index = entry.key;

                            var item = entry.value;

                            int tested = item["totalTested"] ?? 0;

                            double gross = truncateTo2(tested / 144);

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                if (index % 2 == 0) {
                                  return const Color(0xfffafafa);
                                }
                                return null;
                              }),
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15,
                                        child: Text(
                                          item["machine"].toString().substring(
                                            0,
                                            1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        item["machine"].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(tested.toString())),
                                DataCell(
                                  Text(
                                    gross.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
