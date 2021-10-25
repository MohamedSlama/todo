import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/models/task.dart';

class DBHelper {
  static const int _version = 1;
  static const String _tableName = 'tasks';
  static Database? _db;

  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('database is null');
      return;
    } else {
      try {
        //? database initial path
        String _path = await getDatabasesPath() + 'tasks.db';
        debugPrint('create db in $_path');
        _db = await openDatabase(_path, version: _version,
            onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE $_tableName'
            '(id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, note TEXT, date STRING, '
            'startTime STRING, endTime STRING, '
            'remind INTEGER, repeat STRING, '
            'color INTEGER, isCompleted INTEGER )',
          );
          debugPrint('Done from creating database !');
        });
      } catch (e) {
        print(e);
      }
    }
  }

  static Future<int> insert(Task? task) async {
    debugPrint('insert method called !!');

    return await _db!.insert(_tableName, task!.toMap());
  }

  static Future<int> delete(Task? task) async {
    debugPrint('delete method called !!');

    return await _db!
        .delete(_tableName, where: 'id = ?', whereArgs: [task!.id]);
  }

  static Future<int> update(int id) async {
    debugPrint('update method called !!');
    return await _db!.rawUpdate('''
      UPDATE $_tableName
      SET isCompleted = ?
      WHERE id = ?
      ''', [1, id]);
  }

  static Future<List<Map<String, Object?>>> query() async {
    debugPrint('query method called !!');
    return await _db!.query(_tableName);
  }
}
