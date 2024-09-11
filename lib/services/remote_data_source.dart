import 'package:firebase_database/firebase_database.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/todo_data_source.dart';

class RemoteDataSource implements ToDoDataSource {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  @override
  Future<List<ToDo>> fetchTasks() async {
    try {
      final DatabaseReference ref = _firebaseDatabase.ref().child('todos');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.value != null) {
        final data =
            Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        return data.entries.map((entry) {
          final map =
              Map<String, dynamic>.from(entry.value as Map<dynamic, dynamic>);
          return ToDo.fromMap(map);
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching todos: $e');
      throw Exception('Error fetching todos: $e');
    }
  }

  @override
  Future<void> addTask(ToDo todo) async {
    try {
      final DatabaseReference ref = _firebaseDatabase.ref().child('todos');
      final String? id = ref.push().key;

      if (id != null) {
        final todoData = {
          'id': id,
          'complete': todo.isCompleted,
          'name': todo.name,
          'description': todo.description,
        };

        print('Attempting to add todo: $todoData');
        await ref.child(id).set(todoData);
        print('Todo added successfully');
      } else {
        throw Exception('Failed to generate ID for new todo');
      }
    } catch (e) {
      print('Error adding todo: $e');
      throw Exception('Error adding todo: $e');
    }
  }

  @override
  Future<void> updateTask(ToDo task) async {
    try {
      final DatabaseReference ref =
          _firebaseDatabase.ref().child('todos/${task.id}');
      await ref.update({
        'name': task.name,
        'description': task.description,
        'complete': task.isCompleted,
      });
      print('Todo updated successfully');
    } catch (e) {
      print('Error updating todo: $e');
      throw Exception('Error updating todo: $e');
    }
  }

  @override
  Future<void> deleteTask(ToDo task) async {
    try {
      final DatabaseReference ref =
          _firebaseDatabase.ref().child('todos/${task.id}');
      await ref.remove();
      print('Todo deleted successfully');
    } catch (e) {
      print('Error deleting todo: $e');
      throw Exception('Error deleting todo: $e');
    }
  }

  @override
  Future<void> clearTasks() async {
    try {
      final DatabaseReference ref = _firebaseDatabase.ref().child('todos');
      final DataSnapshot snapshot = await ref.get();
      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        for (var entry in data.entries) {
          await ref.child(entry.key).remove();
        }
        print('All todos cleared successfully');
      }
    } catch (e) {
      print('Error clearing todos: $e');
      throw Exception('Error clearing todos: $e');
    }
  }
}
