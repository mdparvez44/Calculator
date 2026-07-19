import 'package:flutter/material.dart';

import '../database/database.dart';
import '../models/production.dart';
import '../utils/constants.dart';

class ProductionProvider extends ChangeNotifier {
  String machine = machines.first;
  String plant = plants.first;
  String productCode = productCodes.first;

  String good = "";
  String reject = "";
  String qa = "";
  String sample = "";

  int currentField = 0;

  // ================= Number Pad =================

  void addNumber(String value) {
    switch (currentField) {
      case 0:
        good += value;
        break;
      case 1:
        reject += value;
        break;
      case 2:
        qa += value;
        break;
      case 3:
        sample += value;
        break;
    }

    notifyListeners();
  }

  void deleteOne() {
    switch (currentField) {
      case 0:
        if (good.isNotEmpty) {
          good = good.substring(0, good.length - 1);
        }
        break;

      case 1:
        if (reject.isNotEmpty) {
          reject = reject.substring(0, reject.length - 1);
        }
        break;

      case 2:
        if (qa.isNotEmpty) {
          qa = qa.substring(0, qa.length - 1);
        }
        break;

      case 3:
        if (sample.isNotEmpty) {
          sample = sample.substring(0, sample.length - 1);
        }
        break;
    }

    notifyListeners();
  }

  void clearCurrent() {
    switch (currentField) {
      case 0:
        good = "";
        break;
      case 1:
        reject = "";
        break;
      case 2:
        qa = "";
        break;
      case 3:
        sample = "";
        break;
    }

    notifyListeners();
  }

  void clearAll() {
    good = "";
    reject = "";
    qa = "";
    sample = "";
    currentField = 0;

    notifyListeners();
  }

  Future<bool> nextField() async {
    if (currentField < 3) {
      currentField++;
      notifyListeners();
      return false;
    }

    try {
      await saveCurrentRecord();
      debugPrint("Record saved successfully");
      clearAll();
      return true;
    } catch (e, s) {
      debugPrint("Save failed: $e");
      debugPrintStack(stackTrace: s);
      return false;
    }
  }

  // ================= Dropdowns =================

  void changeMachine(String value) {
    machine = value;
    notifyListeners();
  }

  void changePlant(String value) {
    plant = value;
    notifyListeners();
  }

  void changeProduct(String value) {
    productCode = value;
    notifyListeners();
  }

  // ================= Next Machine Button =================

  void nextMachine() {
    int index = machines.indexOf(machine);

    if (index == -1) {
      machine = machines.first;
    } else if (index < machines.length - 1) {
      machine = machines[index + 1];
    } else {
      machine = machines.first;
    }

    notifyListeners();
  }

  // ================= Save Data =================
  Future<void> saveCurrentRecord() async {
    try {
      final int goodValue = int.tryParse(good) ?? 0;
      final int rejectValue = int.tryParse(reject) ?? 0;
      final int qaInput = int.tryParse(qa) ?? 0;
      final int qaValue = qaInput * 95;
      final int sampleValue = int.tryParse(sample) ?? 0;

      final production = Production(
        machine: machine,
        plant: plant,
        productCode: productCode,
        good: goodValue,
        reject: rejectValue,
        qa: qaValue,
        sample: sampleValue,
        tested: goodValue + rejectValue + qaValue + sampleValue,
      );

      final id = await DatabaseHelper.instance.insertProduction(production);

      debugPrint("Saved record id = $id");
    } catch (e, s) {
      debugPrint("SAVE ERROR: $e");
      debugPrintStack(stackTrace: s);
    }
  }
}
