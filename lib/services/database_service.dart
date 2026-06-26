import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_manager.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            deadline TEXT NOT NULL,
            status INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'id DESC');
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<int> updateTaskStatus(int id, int status) async {
    final db = await database;
    return db.update('tasks', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getTotalCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tasks WHERE status = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tasks WHERE status = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Debug: print DB path to console so you can pull it with adb
  Future<String> getDbPath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_manager.db');
    // ignore: avoid_print
    print('[DB PATH] $path');
    return path;
  }
}
