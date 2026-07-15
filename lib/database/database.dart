import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/production.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, "production.db");

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future _createDatabase(Database db, int version) async {
    await db.execute('''
CREATE TABLE production(

id INTEGER PRIMARY KEY AUTOINCREMENT,

machine TEXT,

plant TEXT,

productCode TEXT,

good INTEGER,

reject INTEGER,

qa INTEGER,

sample INTEGER,

tested INTEGER

)

''');
  }

  //---------------------------------------------
  // Insert Record
  //---------------------------------------------

  Future<int> insertProduction(Production production) async {
    final db = await database;

    return await db.insert("production", production.toMap());
  }

  //---------------------------------------------
  // Read All Records
  //---------------------------------------------
  Future<List<Production>> getAllProductions() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT *
    FROM production
    ORDER BY
      SUBSTR(machine, 1, 1) ASC,
      CAST(SUBSTR(machine, 2) AS INTEGER) ASC,
      id ASC
  ''');

    return result.map((e) => Production.fromMap(e)).toList();
  }
  //---------------------------------------------
  // Update Record
  //---------------------------------------------

  Future<int> updateProduction(Production production) async {
    final db = await database;

    return await db.update(
      "production",
      production.toMap(),
      where: "id=?",
      whereArgs: [production.id],
    );
  }

  //---------------------------------------------
  // Delete Record
  //---------------------------------------------

  Future<int> deleteProduction(int id) async {
    final db = await database;

    return await db.delete("production", where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteAllProductions() async {
    final db = await database;

    await db.delete("production");
  }

  Future<List<Map<String, dynamic>>> getMachineGross() async {
    final db = await database;

    final result = await db.rawQuery('''

SELECT

machine,

SUM(
  good +
  reject +
  qa +
  sample
) AS totalTested


FROM production


GROUP BY machine


ORDER BY

SUBSTR(machine,1,1),

CAST(SUBSTR(machine,2) AS INTEGER)


''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getDailyReport() async {
    final db = await database;

    final result = await db.rawQuery('''

SELECT

machine,

GROUP_CONCAT(DISTINCT productCode) as productCodes,

SUM(
 good +
 reject +
 qa +
 sample
) as totalTested,

SUM(good) as totalGood,

SUM(reject) as totalReject,

SUM(qa) as totalQA


FROM production


GROUP BY machine

ORDER BY machine


''');

    return result;
  }

  Future<List<Map<String, dynamic>>> getPlantRecord() async {
    final db = await database;

    return await db.rawQuery('''

SELECT
plant,
productCode,

SUM(
 good + reject + qa + sample
) AS totalTested,

SUM(reject) AS totalReject,

SUM(qa) AS totalQA

FROM production

GROUP BY
plant,
productCode

ORDER BY
plant,
productCode;

''');
  }
}
