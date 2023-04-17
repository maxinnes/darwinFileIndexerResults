import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = 'file_info.db';
  static final _databasePath = '/Users/admin/Downloads';

  // Singleton instance
  static DatabaseHelper? _databaseHelperInstance;

  // Private constructor
  DatabaseHelper._privateConstructor();

  // Singleton accessor
  factory DatabaseHelper() {
    _databaseHelperInstance ??= DatabaseHelper._privateConstructor();
    return _databaseHelperInstance!;
  }

  // SQLite database instance
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(_databasePath, _databaseName);
    return await openDatabase(path, readOnly: true);
  }

  // Fetch data from the database
  Future<List<Map<String, dynamic>>> fetchData() async {
    Database db = await database;
    return await db.query('file_info');
  }
}
