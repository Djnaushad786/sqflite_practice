import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static Future<void> createTables(Database database) async {
    await database.execute(''' 
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'dbestech.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print("..creating a table...");
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String title, String? description) async {
    final db = await DatabaseHelper.db();
    final data = {'title': title, 'description': description};
    final id = await db.insert("items", data, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper.db();
    return db.query("items", orderBy: "id");
  }

  static Future<int> updateItem(int id, String title, String? description) async {
    final db = await DatabaseHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };
    return await db.update('items', data, where: 'id=?', whereArgs: [id]);
  }

  static Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete('items', where: 'id=?', whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting your item: $err");
    }
  }
}
