import 'package:todo_flutter/models/todos.dart';

abstract class ToDoDataSource {
  Future<List<ToDo>> fetchTasks();
  Future<void> addTask(ToDo todo);
  Future<void> updateTask(ToDo task);
  Future<void> deleteTask(ToDo task);
  Future<void> clearTasks();
}
