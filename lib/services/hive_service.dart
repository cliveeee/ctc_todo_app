import 'package:hive/hive.dart';
import 'package:todo_flutter/models/todos.dart';

class HiveService {
  final Box<ToDo> _box = Hive.box<ToDo>('todos');

  Future<void> addTask(ToDo task) async {
    await _box.add(task);
  }

  Future<List<ToDo>> fetchTasks() async {
    return _box.values.toList();
  }

  Future<void> updateTask(ToDo task) async {
    await task.save();
  }

  Future<void> deleteTask(ToDo task) async {
    await task.delete();
  }

  Future<void> clearTasks() async {
    await _box.clear();
  }
}
