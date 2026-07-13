import 'package:flutter/material.dart';

import '../database/database.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({super.key});

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();

    loadReport();
  }

  Future<void> loadReport() async {
    final result = await DatabaseHelper.instance.getDailyReport();

    setState(() {
      data = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Report")),

      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: DataTable(
          border: TableBorder.all(),

          columns: [
            "Machine",
            "P.Code",
            "Test Gross",
            "Good Gross",
            "Reject Gross",
            "Hold",
            "QA Samples",
            "Reject %",
          ].map((e) => DataColumn(label: Text(e))).toList(),

          rows: data.map((item) {
            double testedGross = (item["totalTested"] ?? 0) / 144;

            double goodGross = (item["totalGood"] ?? 0) / 144;

            double rejectGross = (item["totalReject"] ?? 0) / 144;

            double qaSamples = (item["totalQA"] ?? 0) / 144;

            double rejectionPercentage = testedGross == 0
                ? 0
                : rejectGross / testedGross * 100;

            return DataRow(
              cells: [
                DataCell(Text(item["machine"])),

                DataCell(Text(item["productCodes"] ?? "")),

                DataCell(Text(testedGross.toStringAsFixed(2))),

                DataCell(Text(goodGross.toStringAsFixed(2))),

                DataCell(Text(rejectGross.toStringAsFixed(2))),

                const DataCell(Text("")),

                DataCell(Text(qaSamples.toStringAsFixed(2))),

                DataCell(Text("${rejectionPercentage.toStringAsFixed(2)}%")),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
