import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'dart:convert';

final data = {
  "items": [
    {"item_code": "2", "qty": "2"},
  ],
};

final String dataAsJson = json.encode(data);

class DatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<void> createOtherTable2(sql.Database database) async {
    await database.execute("""CREATE TABLE Attendance(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    salary TEXT,
    item_ TEXT,
    image TEXT,
    number INTEGER
  )
  """);
  }

  static Future<void> createListTable3(sql.Database database) async {
    await database.execute("""
      CREATE TABLE List(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        item_name TEXT
      )
    """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'Sample.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
        await createOtherTable2(database);
        await createListTable3(database);
      },
    );
  }

  // Create new item
  static Future<int> createItem(
      String? title, String? descrption, String s) async {
    final db = await DatabaseHelper.db();

    final data = {'title': title, 'description': descrption};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> createItem2(
      String? salary, String? number, String base64) async {
    final db = await DatabaseHelper.db();

    final data = {
      'salary': salary,
      'number': number,
      'item_': dataAsJson,
      "image": base64
    };
    final id = await db.insert('Attendance', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItems2() async {
    final db = await DatabaseHelper.db();
    return db.query('Attendance', orderBy: "id");
  }

  // Get a single item by id
  //We dont use this method, it is for you if you want it.
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      int id, String title, String? descrption) async {
    final db = await DatabaseHelper.db();

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<int> updateItem2(int id, String salary, String? number) async {
    final db = await DatabaseHelper.db();
    print("ppppppppppppppppppppppppppp");
    final data = {
      'salary': salary,
      'number': number,
    };

    final result =
        await db.update('Attendance', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteItem2(int id) async {
    print(id);
    print("delete");
    final db = await DatabaseHelper.db();
    try {
      await db.delete("Attendance", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
