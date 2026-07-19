import 'package:flutter/material.dart';

import '../database/database.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  List<Map<String, dynamic>> productData = [];
  List<Map<String, dynamic>> plantData = [];

  double totalTestedGross = 0;
  double totalRejectGross = 0;

  // Added zoom state
  double userZoom = 1.0;

  double truncateTo2(double value) {
    return (value * 100).truncate() / 100;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final plant = await DatabaseHelper.instance.getPlantRecord();
    Map<String, Map<String, dynamic>> productMap = {};

    for (var item in plant) {
      String productCode = item["productCode"].toString();
      if (item["plant"] == "TTK") productCode = "(TTK) $productCode";

      double testedGross = truncateTo2(
        (item["totalTested"] as num).toDouble() / 144,
      );
      double rejectGross = truncateTo2(
        (item["totalReject"] as num).toDouble() / 144,
      );
      double qaGross = truncateTo2((item["totalQ.C"] as num).toDouble() / 144);

      if (!productMap.containsKey(productCode)) {
        productMap[productCode] = {
          "productCode": productCode,
          "testedGross": 0.0,
          "rejectGross": 0.0,
          "Q.C Gross": 0.0,
        };
      }
      productMap[productCode]!["testedGross"] += testedGross;
      productMap[productCode]!["rejectGross"] += rejectGross;
      productMap[productCode]!["Q.C Gross"] += qaGross;
    }

    productData = productMap.values.toList();
    double testedTotal = 0;
    double rejectTotal = 0;

    for (var row in productData) {
      testedTotal += row["testedGross"];
      rejectTotal += row["rejectGross"];
    }

    setState(() {
      plantData = plant;
      totalTestedGross = truncateTo2(testedTotal);
      totalRejectGross = truncateTo2(rejectTotal);
    });
  }

  Widget tableTitle(String title, IconData icon, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * scale),
      child: Row(
        children: [
          Icon(icon, size: 24 * scale),
          SizedBox(width: 8 * scale),
          Text(
            title,
            style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildProductTable(double scale) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10 * scale),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.all(12 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tableTitle("Product Record", Icons.inventory_2, scale),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(color: Colors.black12),
                columnSpacing: 16 * scale,
                horizontalMargin: 10 * scale,
                headingTextStyle: TextStyle(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                dataTextStyle: TextStyle(
                  fontSize: 12 * scale,
                  color: Colors.black,
                ),
                columns: const [
                  DataColumn(label: Text("P.Code")),
                  DataColumn(label: Text("Reject Gross")),
                  DataColumn(label: Text("Q.A Gross")),
                  DataColumn(label: Text("Tested Gross")),
                  DataColumn(label: Text("Reject %")),
                ],
                rows: productData.map((item) {
                  double tested = item["testedGross"];
                  double reject = item["rejectGross"];
                  double qaGross = item["Q.C Gross"];
                  double percentage = tested == 0
                      ? 0
                      : truncateTo2((reject / tested) * 100);

                  return DataRow(
                    cells: [
                      DataCell(Text(item["productCode"].toString())),
                      DataCell(Text(reject.toStringAsFixed(2))),
                      DataCell(Text(qaGross.toStringAsFixed(2))),
                      DataCell(Text(tested.toStringAsFixed(2))),
                      DataCell(Text("${percentage.toStringAsFixed(2)}%")),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlantTable(double scale) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10 * scale),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.all(12 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tableTitle("Plant Record", Icons.factory, scale),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(color: Colors.black12),
                columnSpacing: 16 * scale,
                horizontalMargin: 10 * scale,
                headingTextStyle: TextStyle(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                dataTextStyle: TextStyle(
                  fontSize: 12 * scale,
                  color: Colors.black,
                ),
                columns: const [
                  DataColumn(label: Text("Plant")),
                  DataColumn(label: Text("P.Code")),
                  DataColumn(label: Text("Tested Gross")),
                  DataColumn(label: Text("Reject Gross")),
                  DataColumn(label: Text("Reject %")),
                ],
                rows: plantData.map((item) {
                  double tested = truncateTo2(
                    (item["totalTested"] as num).toDouble() / 144,
                  );
                  double reject = truncateTo2(
                    (item["totalReject"] as num).toDouble() / 144,
                  );
                  double percentage = tested == 0
                      ? 0
                      : truncateTo2((reject / tested) * 100);

                  return DataRow(
                    cells: [
                      DataCell(Text(item["plant"].toString())),
                      DataCell(Text(item["productCode"].toString())),
                      DataCell(Text(tested.toStringAsFixed(2))),
                      DataCell(Text(reject.toStringAsFixed(2))),
                      DataCell(Text("${percentage.toStringAsFixed(2)}%")),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply userZoom to the screen scaling
    double scale = (MediaQuery.of(context).size.width / 375) * userZoom;
    double overallRejectPercentage = totalTestedGross == 0
        ? 0
        : truncateTo2((totalRejectGross / totalTestedGross) * 100);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Production Record",
          style: TextStyle(fontSize: 20 * scale),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24 * scale),
            onPressed: loadData,
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
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          children: [
            Card(
              elevation: 5,
              margin: EdgeInsets.all(12 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16 * scale),
              ),
              child: Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  children: [
                    Text(
                      "Overall Production",
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    Text(
                      "Tested Gross : ${totalTestedGross.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 15 * scale),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      "Reject Gross : ${totalRejectGross.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 15 * scale),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      "Reject % : ${overallRejectPercentage.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            buildProductTable(scale),
            buildPlantTable(scale),
            SizedBox(height: 20 * scale),
          ],
        ),
      ),
    );
  }
}
