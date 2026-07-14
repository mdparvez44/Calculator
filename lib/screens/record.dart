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

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    final product = await DatabaseHelper.instance.getProductRecord();

    final plant = await DatabaseHelper.instance.getPlantRecord();

    double tested = 0;

    double reject = 0;

    for (var item in product) {
      tested += (item["totalTested"] ?? 0) / 144;

      reject += (item["totalReject"] ?? 0) / 144;
    }

    setState(() {
      productData = product;

      plantData = plant;

      totalTestedGross = tested;

      totalRejectGross = reject;
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
                  double tested = (item["totalTested"] ?? 0) / 144;

                  double reject = (item["totalReject"] ?? 0) / 144;

                  double qaGross = (item["totalQA"] ?? 0) / 144;

                  double percentage = tested == 0 ? 0 : (reject / tested) * 100;

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
                  double tested = (item["totalTested"] ?? 0) / 144;

                  double reject = (item["totalReject"] ?? 0) / 144;

                  double percentage = tested == 0 ? 0 : (reject / tested) * 100;

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
        : (totalRejectGross / totalTestedGross) * 100;

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
