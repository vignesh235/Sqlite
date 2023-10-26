import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DatabaseHelper_ extends GetxController {
  var selectedImagePath = ''.obs;
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

  static Future<void> createTables1(sql.Database database) async {
    await database.execute("""CREATE TABLE image(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        image TEXT,
        doc TEXT,
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
        await createTables1(database);
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

  Future<int> createItem1(String? customer, String? base64) async {
    final db = await DatabaseHelper_.db();
    print('pppppppppppppppppppppppppppppppppppppppp');
    final data = {'doc': customer, 'image': base64};
    final id = await db.insert('image', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper_.db();
    return db.query('sales_order', orderBy: "id");
  }

  Future<List<Map<String, dynamic>>> getItems1() async {
    final db = await DatabaseHelper_.db();
    return db.query('image', orderBy: "id");
  }

  Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper_.db();
    try {
      await db.delete("sales_order", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future<void> deleteItem1(int id) async {
    final db = await DatabaseHelper_.db();
    try {
      await db.delete("image", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteItem2(int id) async {
    print(id);
    print("delete");
    final db = await DatabaseHelper_.db();
    try {
      await db.delete("sales_order", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var item_ = await getItems1();
      selectedImagePath.value = pickedFile.path;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        createItem1("CUST-2023-00001", selectedImagePath.value.toString());
      } else {
        uploadImage(item_);
      }

      // uploadImage(File(selectedImagePath.value));

      print("-------------------------------after-------delection");
      print(item_);
    }
  }

  Future<void> uploadImage(item_) async {
    print("-----------------------------imageupload-------------------------");

    for (var i in item_) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://smb.thirvusoft.co.in/api/method/upload_file"),
      );

      request.headers['Authorization'] =
          "token 9f1554dc70f9808:38af0adb0caa516";

      request.fields['docname'] = i["doc"];
      request.fields['doctype'] = "Customer";
      request.fields['attached_to_name'] = i["doc"];
      request.fields['is_private'] = '0';
      request.fields['folder'] = 'Home/Attachments';
      String fileName = File(i["image"]).path.split('/').last;
      // Open the file for reading
      // final fileStream = http.ByteStream(imageFile.openRead());

      request.files.add(await http.MultipartFile.fromPath(
          'file', File(i["image"]).path,
          filename: fileName));
      // final multipartFile = http.MultipartFile(
      //   'file',
      //   imageFile,
      //   length,
      //   filename: fileName, // Use the file path as the filename
      // );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(
          "*****************************************************************************************");
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        print('Image uploaded successfully');

        deleteItem1(i["id"]);
      } else {
        print('Image upload failed with status code: ${response.statusCode}');
      }
    }
  }
}
