import 'dart:io';

import 'package:excel/excel.dart' hide Border; // FIXED EXCEL CONFLICT
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  bool isLoading = false;

  // Added zoom state
  double userZoom = 1.0;

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

  Future<void> deleteAll(double scale) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          title: Text(
            "Delete All Records?",
            style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "All production data will be removed permanently.",
            style: TextStyle(fontSize: 14 * scale),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel", style: TextStyle(fontSize: 14 * scale)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white, fontSize: 14 * scale),
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

  // EXCEL LOGIC
  Future<void> exportToExcel() async {
    if (records.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No records to export!")));
      return;
    }
    setState(() => isLoading = true);
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Production Data'];
      excel.setDefaultSheet('Production Data');

      sheet.appendRow([
        TextCellValue("Machine"),
        TextCellValue("Plant"),
        TextCellValue("Product Code"),
        TextCellValue("Good"),
        TextCellValue("Reject"),
        TextCellValue("Q.C"),
        TextCellValue("Sample"),
        TextCellValue("Tested"),
      ]);

      for (var item in records) {
        sheet.appendRow([
          TextCellValue(item.machine),
          TextCellValue(item.plant),
          TextCellValue(item.productCode),
          IntCellValue(item.good),
          IntCellValue(item.reject),
          IntCellValue(item.qa),
          IntCellValue(item.sample),
          IntCellValue(item.tested),
        ]);
      }

      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getTemporaryDirectory();
        String dateStr =
            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
        final filePath = '${directory.path}/Production_Report_$dateStr.xlsx';
        File file = File(filePath);
        await file.writeAsBytes(fileBytes);
        await Share.shareXFiles([
          XFile(filePath),
        ], text: "Daily Production Report - $dateStr");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Export failed: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> importFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() => isLoading = true);
        var bytes = File(result.files.single.path!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);
        int importedCount = 0;

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet == null) continue;
          for (int i = 1; i < sheet.maxRows; i++) {
            var row = sheet.rows[i];
            if (row.isEmpty || row[0]?.value == null) continue;

            String machine = row[0]?.value.toString() ?? "";
            String plant = row[1]?.value.toString() ?? "";
            String productCode = row[2]?.value.toString() ?? "";
            int good = int.tryParse(row[3]?.value.toString() ?? "0") ?? 0;
            int reject = int.tryParse(row[4]?.value.toString() ?? "0") ?? 0;
            int qa = int.tryParse(row[5]?.value.toString() ?? "0") ?? 0;
            int sample = int.tryParse(row[6]?.value.toString() ?? "0") ?? 0;
            int tested =
                int.tryParse(row[7]?.value.toString() ?? "0") ??
                (good + reject + qa + sample);

            Production newRecord = Production(
              machine: machine,
              plant: plant,
              productCode: productCode,
              good: good,
              reject: reject,
              qa: qa,
              sample: sample,
              tested: tested,
            );
            await DatabaseHelper.instance.insertProduction(newRecord);
            importedCount++;
          }
        }
        await loadData();
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Successfully imported $importedCount records!"),
            ),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Import failed. Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget headerCell(String text, double scale) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(4 * scale),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * scale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply userZoom to the screen scaling
    double scale = (MediaQuery.of(context).size.width / 375) * userZoom;

    return Scaffold(
      backgroundColor: const Color(0xffeeeeee),
      appBar: AppBar(
        title: Text(
          "Production Input Sheet",
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.all(8 * scale),
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8 * scale),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "TOTAL RECORDS : ${records.length}",
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * scale),
                      Wrap(
                        spacing: 8 * scale,
                        runSpacing: 8 * scale,
                        alignment: WrapAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 8 * scale,
                              ),
                            ),
                            icon: Icon(Icons.upload_file, size: 20 * scale),
                            label: Text(
                              "Import Excel",
                              style: TextStyle(fontSize: 13 * scale),
                            ),
                            onPressed: importFromExcel,
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 8 * scale,
                              ),
                            ),
                            icon: Icon(Icons.download, size: 20 * scale),
                            label: Text(
                              "Export Excel",
                              style: TextStyle(fontSize: 13 * scale),
                            ),
                            onPressed: exportToExcel,
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 8 * scale,
                              ),
                            ),
                            icon: Icon(Icons.delete_forever, size: 20 * scale),
                            label: Text(
                              "Delete All",
                              style: TextStyle(fontSize: 13 * scale),
                            ),
                            onPressed: () => deleteAll(scale),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: records.isEmpty
                      ? Center(
                          child: Text(
                            "No Production Records",
                            style: TextStyle(fontSize: 16 * scale),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.all(8 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor:
                                    MaterialStateProperty.resolveWith(
                                      (states) => const Color(0xffdddddd),
                                    ),
                                dataRowMinHeight: 35 * scale,
                                dataRowMaxHeight: 45 * scale,
                                headingRowHeight: 45 * scale,
                                columnSpacing: 20 * scale,
                                border: TableBorder.all(color: Colors.black12),
                                dataTextStyle: TextStyle(
                                  fontSize: 13 * scale,
                                  color: Colors.black87,
                                ),
                                columns: [
                                  DataColumn(label: headerCell("No", scale)),
                                  DataColumn(
                                    label: headerCell("Machine", scale),
                                  ),
                                  DataColumn(
                                    label: headerCell("Product", scale),
                                  ),
                                  DataColumn(label: headerCell("Plant", scale)),
                                  DataColumn(
                                    label: headerCell("Tested", scale),
                                  ),
                                  DataColumn(label: headerCell("Good", scale)),
                                  DataColumn(
                                    label: headerCell("Reject", scale),
                                  ),
                                  DataColumn(label: headerCell("Q.C", scale)),
                                  DataColumn(
                                    label: headerCell("Sample", scale),
                                  ),
                                  DataColumn(label: headerCell("", scale)),
                                ],
                                rows: records.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Production item = entry.value;

                                  return DataRow(
                                    color:
                                        MaterialStateProperty.resolveWith<
                                          Color?
                                        >((states) {
                                          if (index % 2 == 0)
                                            return const Color(0xfffafafa);
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
                                      DataCell(
                                        Center(child: Text("${index + 1}")),
                                      ),
                                      DataCell(Text(item.machine)),
                                      DataCell(Text(item.productCode)),
                                      DataCell(Text(item.plant)),
                                      DataCell(
                                        Text(
                                          (item.good + item.reject + item.qa)
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(item.good.toString())),
                                      DataCell(Text(item.reject.toString())),
                                      DataCell(Text(item.qa.toString())),
                                      DataCell(Text(item.sample.toString())),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20 * scale,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
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
