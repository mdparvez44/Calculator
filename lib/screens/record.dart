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

      if (item["plant"] == "TTK") {
        productCode = "(TTK) $productCode";
      }

      double testedGross = truncateTo2(
        (item["totalTested"] as num).toDouble() / 144,
      );

      double rejectGross = truncateTo2(
        (item["totalReject"] as num).toDouble() / 144,
      );

      double qaGross = truncateTo2((item["totalQA"] as num).toDouble() / 144);

      if (!productMap.containsKey(productCode)) {
        productMap[productCode] = {
          "productCode": productCode,
          "testedGross": 0.0,
          "rejectGross": 0.0,
          "qaGross": 0.0,
        };
      }

      productMap[productCode]!["testedGross"] += testedGross;
      productMap[productCode]!["rejectGross"] += rejectGross;
      productMap[productCode]!["qaGross"] += qaGross;
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

  Widget tableTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildProductTable() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tableTitle("Product Record", Icons.inventory_2),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(),
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
                  double qaGross = item["qaGross"];

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

  Widget buildPlantTable() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tableTitle("Plant Record", Icons.factory),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                border: TableBorder.all(),

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
    double overallRejectPercentage = totalTestedGross == 0
        ? 0
        : truncateTo2((totalRejectGross / totalTestedGross) * 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Production Record"),

        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadData),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadData,

        child: ListView(
          children: [
            Card(
              elevation: 5,

              margin: const EdgeInsets.all(12),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    const Text(
                      "Overall Production",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Tested Gross : ${totalTestedGross.toStringAsFixed(2)}",
                    ),

                    Text(
                      "Reject Gross : ${totalRejectGross.toStringAsFixed(2)}",
                    ),

                    Text(
                      "Reject % : ${overallRejectPercentage.toStringAsFixed(2)}%",
                    ),
                  ],
                ),
              ),
            ),

            buildProductTable(),

            buildPlantTable(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
