import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/todo_data_source.dart';

class SQLiteService implements ToDoDataSource {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;

  SQLiteService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id TEXT PRIMARY KEY, name TEXT, description TEXT, isCompleted INTEGER)',
        );
      },
      version: 2, // Increment the version number for schema changes
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Handle any migrations needed here if necessary
        }
      },
    );
  }

  @override
  Future<void> addTask(ToDo task) async {
    final db = await database;

    await db.insert(
      'todos',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ToDo>> fetchTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return ToDo.fromMap(maps[i]);
    });
  }

  @override
  Future<void> updateTask(ToDo task) async {
    final db = await database;
    await db.update(
      'todos',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(ToDo task) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> clearTasks() async {
    final db = await database;
    await db.delete('todos');
  }
}
