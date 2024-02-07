import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase("bn_bayaan.db");
    return _database!;
  }

  Future<Database> initDatabase(String dbName) async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    // Check if the database file exists in the documents directory
    if (!await databaseExists(path)) {
      // Copy the database from assets to the documents directory
      await _copyDatabase(path, dbName);
    }

    // Open the database with read and write access
    return await openDatabase(
      path,
      version: 4,
      readOnly: false,
    );
  }

  Future<void> _copyDatabase(String path, dbName) async {
    // Get the asset database file
    ByteData data = await rootBundle.load('lib/assets/documents/$dbName');
    List<int> bytes = data.buffer.asUint8List();

    // Write the bytes to the database file
    await File(path).writeAsBytes(bytes, flush: true);
  }

  Future<List<Map<String, dynamic>>> fetchData(var dbName) async {
    final Database db = await database;

    // Get all table names from the database
    var tableNames = await db.rawQuery("SELECT name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%'");
    var tableData = await db.rawQuery("SELECT * FROM verses");
    print(tableData);
    print(tableNames);

    // Return the table names
    return tableNames;
  }
}
