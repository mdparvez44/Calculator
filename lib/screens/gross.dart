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

  // Added zoom state
  double userZoom = 1.0;

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
    });
  }

  Widget summaryBox(String title, String value, IconData icon, double scale) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(4 * scale),
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10 * scale),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24 * scale),
            SizedBox(height: 5 * scale),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(fontSize: 11 * scale, color: Colors.black54),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header(String text, double scale) {
    return Padding(
      padding: EdgeInsets.all(6 * scale),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Multiply base scale by our userZoom
    double scale = (MediaQuery.of(context).size.width / 375) * userZoom;

    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      appBar: AppBar(
        title: Text(
          "Machine Gross Sheet",
          style: TextStyle(fontSize: 18 * scale),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24 * scale),
            onPressed: loadGross,
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
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(6 * scale),
            child: Row(
              children: [
                summaryBox(
                  "Machines",
                  data.length.toString(),
                  Icons.precision_manufacturing,
                  scale,
                ),
                summaryBox(
                  "Tested",
                  totalTested.toString(),
                  Icons.check_circle,
                  scale,
                ),
              ],
            ),
          ),
          Expanded(
            child: data.isEmpty
                ? Center(
                    child: Text(
                      "No Production Data",
                      style: TextStyle(fontSize: 18 * scale),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.all(8 * scale),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 45 * scale,
                          dataRowMinHeight: 35 * scale,
                          dataRowMaxHeight: 45 * scale,
                          columnSpacing: 25 * scale,
                          border: TableBorder.all(color: Colors.black12),
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => const Color(0xffdddddd),
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 13 * scale,
                            color: Colors.black87,
                          ),
                          columns: [
                            DataColumn(label: header("Machine", scale)),
                            DataColumn(label: header("Tested", scale)),
                          ],
                          rows: data.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            int tested = item["totalTested"] ?? 0;

                            return DataRow(
                              color: MaterialStateProperty.resolveWith<Color?>((
                                states,
                              ) {
                                if (index % 2 == 0)
                                  return const Color(0xfffafafa);
                                return null;
                              }),
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12 * scale,
                                        backgroundColor:
                                            Colors.blueGrey.shade100,
                                        child: Text(
                                          item["machine"].toString().substring(
                                            0,
                                            1,
                                          ),
                                          style: TextStyle(
                                            fontSize: 12 * scale,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8 * scale),
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
