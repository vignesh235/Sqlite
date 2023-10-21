import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper_ extends GetxController {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE sales_order(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        customer TEXT,
        item TEXT,
        image TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'offline.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  Future<int> createItem(String? customer, String? base64, String? item) async {
    final db = await DatabaseHelper_.db();

    final data = {'customer': customer, 'item': item, 'image': base64};
    final id = await db.insert('sales_order', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper_.db();
    return db.query('sales_order', orderBy: "id");
  }

  Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper_.db();
    try {
      await db.delete("sales_order", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
