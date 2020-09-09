import 'dart:io';

import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tafseer_hafiz_abdusalam/Constants/Constants.dart';
import 'package:tafseer_hafiz_abdusalam/Models/AyatModel.dart';

class DbManager {
  static DbManager _databaseManger;
  static Database _database;

  DbManager._createInstance();

  factory DbManager() {
    if (_databaseManger == null) {
      _databaseManger = DbManager._createInstance();
    }
    return _databaseManger;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, Constants.DB_NAME);

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "tafsir.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);

    } else {
      print("Opening existing database");
    }

    return await openDatabase(path);
  }

  Future<List<Map<String, dynamic>>> getMapList(String column, int position) async {
    Database db = await this.database;
    
    return await db.query(Constants.DATA, where: '$column = ?', whereArgs: [position]);
  }

  Future<List<AyatModel>> getSurah(String column, int position) async {
    var mapList = await getMapList(column, position);
    int count = mapList.length;

    List<AyatModel> list = new List<AyatModel>();
    
    for(int i = 0; i<count; i++){
      list.add(AyatModel.fromMapObject(mapList[i]));
    }

    return list;

  }


}
