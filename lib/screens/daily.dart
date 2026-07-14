import 'package:flutter/material.dart';

import '../database/database.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({super.key});

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  List<Map<String, dynamic>> data = [];

  double totalTested = 0;

  double totalReject = 0;

  double totalGood = 0;

  @override
  void initState() {
    super.initState();

    loadReport();
  }

  Future<void> loadReport() async {
    final result = await DatabaseHelper.instance.getDailyReport();

    double tested = 0;

    double reject = 0;

    double good = 0;

    for (var item in result) {
      tested += (item["totalTested"] ?? 0) / 144;

      reject += (item["totalReject"] ?? 0) / 144;

      good += (item["totalGood"] ?? 0) / 144;
    }

    setState(() {
      data = result;

      totalTested = tested;

      totalReject = reject;

      totalGood = good;
    });
  }

  Widget reportBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),

        margin: const EdgeInsets.all(5),

        decoration: BoxDecoration(border: Border.all(color: Colors.black26)),

        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),

            const SizedBox(height: 4),

            Text(
              value,

              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(6),

      child: Text(
        text,

        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double rejectPercent = totalTested == 0
        ? 0
        : (totalReject / totalTested) * 100;

    return Scaffold(
      backgroundColor: const Color(0xffdddddd),

      appBar: AppBar(
        title: const Text("Daily Production Report"),

        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadReport),
        ],
      ),

      body: Center(
        child: Container(
          width: 900,

          margin: const EdgeInsets.all(15),

          padding: const EdgeInsets.all(20),

          color: Colors.white,

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "DAILY PRODUCTION REPORT",

                        style: TextStyle(
                          fontSize: 24,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Date : ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    reportBox("Tested Gross", totalTested.toStringAsFixed(2)),

                    reportBox("Good Gross", totalGood.toStringAsFixed(2)),

                    reportBox("Reject Gross", totalReject.toStringAsFixed(2)),

                    reportBox(
                      "Reject %",
                      "${rejectPercent.toStringAsFixed(2)}%",
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  child: DataTable(
                    border: TableBorder.all(color: Colors.black),

                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xffdddddd),
                    ),

                    columns: [
                      DataColumn(label: tableHeader("Machine")),

                      DataColumn(label: tableHeader("P.Code")),

                      DataColumn(label: tableHeader("Test Gross")),

                      DataColumn(label: tableHeader("Good Gross")),

                      DataColumn(label: tableHeader("Reject Gross")),

                      DataColumn(label: tableHeader("Hold")),

                      DataColumn(label: tableHeader("QA")),

                      DataColumn(label: tableHeader("Reject %")),
                    ],

                    rows: data.map((item) {
                      double tested = (item["totalTested"] ?? 0) / 144;

                      double good = (item["totalGood"] ?? 0) / 144;

                      double reject = (item["totalReject"] ?? 0) / 144;

                      double qa = (item["totalQA"] ?? 0) / 144;

                      double percent = tested == 0
                          ? 0
                          : (reject / tested) * 100;

                      return DataRow(
                        cells: [
                          DataCell(Text(item["machine"])),

                          DataCell(Text(item["productCodes"] ?? "")),

                          DataCell(Text(tested.toStringAsFixed(2))),

                          DataCell(Text(good.toStringAsFixed(2))),

                          DataCell(Text(reject.toStringAsFixed(2))),

                          const DataCell(Text("")),

                          DataCell(Text(qa.toStringAsFixed(2))),

                          DataCell(Text("${percent.toStringAsFixed(2)}%")),
                        ],
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 40),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Prepared By : __________"),

                    Text("Checked By : __________"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
