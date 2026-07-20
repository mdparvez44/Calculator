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
  double totalQA = 0;
  double totalGood = 0;

  // Added zoom state
  double userZoom = 1.0;

  double truncateTo2(double value) {
    return (value * 100).truncate() / 100;
  }

  double toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  Future<void> loadReport() async {
    final result = await DatabaseHelper.instance.getDailyReport();
    double tested = 0;
    double reject = 0;
    double qa = 0;
    double good = 0;

    for (var item in result) {
      tested += toDouble(item["totalTested"]) / 144;
      reject += toDouble(item["totalReject"]) / 144;
      qa += toDouble(item["totalQA"] ?? item["totalQ.C"]) / 144;
    }
    good = truncateTo2(tested) - truncateTo2(reject) - truncateTo2(qa);

    setState(() {
      data = result;
      totalTested = truncateTo2(tested);
      totalReject = truncateTo2(reject);
      totalQA = truncateTo2(qa);
      totalGood = good;
    });
  }

  Widget reportBox(String title, String value, double scale) {
    return Container(
      constraints: const BoxConstraints(minWidth: 65),
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 8 * scale),
      margin: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: Colors.black26),
        boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(fontSize: 11 * scale, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 4 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tableHeader(String text, double scale) {
    return Padding(
      padding: EdgeInsets.all(4 * scale),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12 * scale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply userZoom to the screen scaling
    double scale = (MediaQuery.of(context).size.width / 375).clamp(0.8, 1.4) * userZoom;
    double rejectPercent = totalTested == 0
        ? 0
        : truncateTo2((totalReject / totalTested) * 100);

    return Scaffold(
      backgroundColor: const Color(0xffdddddd),
      appBar: AppBar(
        title: Text(
          "Daily Production Report",
          style: TextStyle(fontSize: 18 * scale),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24 * scale),
            onPressed: loadReport,
          ),
        ],
      ),
      // Zoom Controls
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            mini: true,
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            onPressed: () => setState(() => userZoom += 0.15),
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: null,
            mini: true,
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            onPressed: () => setState(() {
              if (userZoom > 0.5) userZoom -= 0.15;
            }),
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(8 * scale),
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12 * scale),
            boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12)],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        "DAILY PRODUCTION REPORT",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        "Date : ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                        style: TextStyle(fontSize: 13 * scale),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14 * scale),
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isNarrow = constraints.maxWidth < 420;
                    if (isNarrow) {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4 * scale,
                        runSpacing: 6 * scale,
                        children: [
                          reportBox("Tested Gross", totalTested.toStringAsFixed(2), scale),
                          reportBox("Good Gross", totalGood.toStringAsFixed(2), scale),
                          reportBox("Reject Gross", totalReject.toStringAsFixed(2), scale),
                          reportBox("Q.C Gross", totalQA.toStringAsFixed(2), scale),
                          reportBox("Reject %", "${rejectPercent.toStringAsFixed(2)}%", scale),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: reportBox("Tested Gross", totalTested.toStringAsFixed(2), scale)),
                        Expanded(child: reportBox("Good Gross", totalGood.toStringAsFixed(2), scale)),
                        Expanded(child: reportBox("Reject Gross", totalReject.toStringAsFixed(2), scale)),
                        Expanded(child: reportBox("Q.C Gross", totalQA.toStringAsFixed(2), scale)),
                        Expanded(child: reportBox("Reject %", "${rejectPercent.toStringAsFixed(2)}%", scale)),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16 * scale),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.black12),
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xffdddddd),
                    ),
                    columnSpacing: 14 * scale,
                    dataRowMinHeight: 35 * scale,
                    dataRowMaxHeight: 45 * scale,
                    headingRowHeight: 45 * scale,
                    dataTextStyle: TextStyle(
                      fontSize: 12 * scale,
                      color: Colors.black87,
                    ),
                    columns: [
                      DataColumn(label: tableHeader("Machine", scale)),
                      DataColumn(label: tableHeader("P.Code", scale)),
                      DataColumn(label: tableHeader("Test Gross", scale)),
                      DataColumn(label: tableHeader("Good Gross", scale)),
                      DataColumn(label: tableHeader("Reject Gross", scale)),
                      DataColumn(label: tableHeader("Hold", scale)),
                      DataColumn(label: tableHeader("Q.C", scale)),
                      DataColumn(label: tableHeader("Reject %", scale)),
                    ],
                    rows: data.map((item) {
                      double tested = truncateTo2(
                        toDouble(item["totalTested"]) / 144,
                      );
                      double reject = truncateTo2(
                        toDouble(item["totalReject"]) / 144,
                      );
                      double qa = truncateTo2(toDouble(item["totalQA"] ?? item["totalQ.C"]) / 144);
                      double sample = truncateTo2(
                        toDouble(item["totalSample"]) / 144,
                      );
                      double good = truncateTo2(
                        tested - (reject + qa + sample),
                      );
                      double percent = tested == 0
                          ? 0
                          : truncateTo2((reject / tested) * 100);

                      return DataRow(
                        cells: [
                          DataCell(Text(item["machine"].toString())),
                          DataCell(
                            Text(item["productCodes"]?.toString() ?? ""),
                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
