import 'package:hive/hive.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/todo_data_source.dart';

class HiveService implements ToDoDataSource {
  final Box<ToDo> _box;

  HiveService(this._box);

  @override
  Future<void> addTask(ToDo task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<List<ToDo>> fetchTasks() async {
    return _box.values.toList();
  }

  @override
  Future<void> updateTask(ToDo task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(ToDo task) async {
    await _box.delete(task.id);
  }

  @override
  Future<void> clearTasks() async {
    await _box.clear();
  }
}
