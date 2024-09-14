import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/todo_data_source.dart';

class SQLiteService implements ToDoDataSource {
  static Database? _database;

  // Make sure to initialize SQLite asynchronously
  static Future<SQLiteService> createAsync() async {
    SQLiteService instance = SQLiteService();
    await instance._initDatabase();
    return instance;
  }

  // Initialize the SQLite database
  Future<void> _initDatabase() async {
    if (_database == null) {
      _database = await openDatabase(
        join(await getDatabasesPath(), 'todos.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE todos(id TEXT PRIMARY KEY, name TEXT, description TEXT, isCompleted INTEGER)',
          );
        },
        version: 1,
      );
    }
  }

  // Implement CRUD methods for SQLite
  @override
  Future<void> addTask(ToDo todo) async {
    final db = _database;
    if (db != null) {
      await db.insert('todos', todo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  @override
  Future<List<ToDo>> fetchTasks() async {
    final db = _database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query('todos');
      return List.generate(maps.length, (i) {
        return ToDo(
          id: maps[i]['id'],
          name: maps[i]['name'],
          description: maps[i]['description'],
          isCompleted: maps[i]['isCompleted'] == 1,
        );
      });
    }
    return [];
  }

  @override
  Future<void> updateTask(ToDo task) async {
    final db = _database;
    if (db != null) {
      await db
          .update('todos', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
    }
  }

  @override
  Future<void> deleteTask(ToDo task) async {
    final db = _database;
    if (db != null) {
      await db.delete('todos', where: 'id = ?', whereArgs: [task.id]);
    }
  }

  @override
  Future<void> clearTasks() async {
    final db = _database;
    if (db != null) {
      await db.delete('todos');
    }
  }
}
