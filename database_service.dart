import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/password_entry.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'passwords';

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'password_vault.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            category TEXT NOT NULL,
            website TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> insertPassword(PasswordEntry entry) async {
    final db = await database;
    await db.insert(_tableName, entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<PasswordEntry>> getAllPasswords() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'updated_at DESC');
    return maps.map((e) => PasswordEntry.fromMap(e)).toList();
  }

  static Future<List<PasswordEntry>> getPasswordsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'updated_at DESC',
    );
    return maps.map((e) => PasswordEntry.fromMap(e)).toList();
  }

  static Future<List<PasswordEntry>> searchPasswords(String query) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'title LIKE ? OR username LIKE ? OR website LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return maps.map((e) => PasswordEntry.fromMap(e)).toList();
  }

  static Future<void> updatePassword(PasswordEntry entry) async {
    final db = await database;
    await db.update(
      _tableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  static Future<void> deletePassword(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> getTotalCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
