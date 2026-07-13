import 'package:flutter/material.dart';

import '../database/database.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  List<Map<String, dynamic>> data = [];

  double totalTestedGross = 0;

  double totalRejectGross = 0;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    final result = await DatabaseHelper.instance.getProductRecord();

    double tested = 0;

    double reject = 0;

    for (var item in result) {
      tested += (item["totalTested"] ?? 0) / 144;

      reject += (item["totalReject"] ?? 0) / 144;
    }

    setState(() {
      data = result;

      totalTestedGross = tested;

      totalRejectGross = reject;
    });
  }

  @override
  Widget build(BuildContext context) {
    double overallRejectPercentage = totalTestedGross == 0
        ? 0
        : (totalRejectGross / totalTestedGross) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text("Product Record")),

      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                children: [
                  Text(
                    "Overall Tested Gross : ${totalTestedGross.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Overall Reject Gross : ${totalRejectGross.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Overall Reject % : ${overallRejectPercentage.toStringAsFixed(2)}%",
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: DataTable(
                border: TableBorder.all(),

                columns: const [
                  DataColumn(label: Text("P.Code")),

                  DataColumn(label: Text("Tested Gross")),

                  DataColumn(label: Text("Reject Gross")),

                  DataColumn(label: Text("Reject %")),
                ],

                rows: data.map((item) {
                  double testedGross = (item["totalTested"] ?? 0) / 144;

                  double rejectGross = (item["totalReject"] ?? 0) / 144;

                  double percentage = testedGross == 0
                      ? 0
                      : (rejectGross / testedGross) * 100;

                  return DataRow(
                    cells: [
                      DataCell(Text(item["productCode"])),

                      DataCell(Text(testedGross.toStringAsFixed(2))),

                      DataCell(Text(rejectGross.toStringAsFixed(2))),

                      DataCell(Text("${percentage.toStringAsFixed(2)}%")),
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
