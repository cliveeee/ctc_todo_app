import 'package:flutter/material.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/todo_data_source.dart';

class TodoProvider with ChangeNotifier {
  final ToDoDataSource dataSource;
  List<ToDo> _tasks = [];

  List<ToDo> get tasks => _tasks;

  TodoProvider({required this.dataSource}) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _tasks = await dataSource.fetchTasks();
    notifyListeners();
  }

  Future<void> addTask(ToDo task) async {
    await dataSource.addTask(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(ToDo task) async {
    await dataSource.updateTask(task);
    notifyListeners();
  }

  Future<void> deleteTask(ToDo task) async {
    await dataSource.deleteTask(task);
    _tasks.remove(task);
    notifyListeners();
  }

  Future<void> clearAllTasks() async {
    await dataSource.clearTasks();
    _tasks.clear();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(ToDo task, bool? isCompleted) async {
    task.isCompleted = isCompleted ?? false;

    await updateTask(task);

    notifyListeners();
  }
}
