import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/hive_service.dart';
import 'package:todo_flutter/services/sqlite_service.dart';
import 'package:todo_flutter/services/remote_data_source.dart';
import 'package:todo_flutter/services/todo_data_source.dart';
import 'package:http/http.dart' as http;

class ToDoDataSourceFactory implements ToDoDataSource {
  static ToDoDataSource? _instance;
  late ToDoDataSource _local;
  ToDoDataSource? _remote;

  ToDoDataSourceFactory();

  static Future<bool> _isInternetAvailable() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com'));
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<ToDoDataSource> create() async {
    if (_instance != null) {
      return _instance!;
    }

    ToDoDataSourceFactory service = ToDoDataSourceFactory();

    final isInternetAvailable = await _isInternetAvailable();
    if (isInternetAvailable) {
      print('Using RemoteDatabase (Firebase)');
      service._remote = RemoteDataSource();
    }

    if (kIsWeb) {
      var box = await Hive.openBox<ToDo>('todos');
      print('Using Hive database for web');
      service._local = HiveService(box);
    } else if (Platform.isAndroid || Platform.isIOS) {
      print('Using SQLite database for mobile');
      service._local = await SQLiteService.createAsync();
    } else {
      throw Exception('Unsupported platform');
    }

    _instance = service;
    return _instance!;
  }

  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none &&
        await _isInternetAvailable();
  }

  @override
  Future<List<ToDo>> fetchTasks() async {
    try {
      if (await isConnected() && _remote != null) {
        print('Fetching todos from Firebase');
        return _remote!.fetchTasks();
      } else {
        print('Fetching todos from local database');
        return _local.fetchTasks();
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  @override
  Future<void> addTask(ToDo todo) async {
    try {
      if (await isConnected() && _remote != null) {
        print('Adding todo to Firebase');
        await _remote!.addTask(todo);
      } else {
        print('Adding todo to local database');
        await _local.addTask(todo);
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  @override
  Future<void> updateTask(ToDo task) async {
    try {
      if (await isConnected() && _remote != null) {
        print('Updating todo on Firebase');
        await _remote!.updateTask(task);
      } else {
        print('Updating todo on local database');
        await _local.updateTask(task);
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  @override
  Future<void> deleteTask(ToDo task) async {
    try {
      if (await isConnected() && _remote != null) {
        print('Deleting todo from Firebase');
        await _remote!.deleteTask(task);
      } else {
        print('Deleting todo from local database');
        await _local.deleteTask(task);
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  @override
  Future<void> clearTasks() async {
    try {
      if (await isConnected() && _remote != null) {
        print('Clearing todos from Firebase');
        await _remote!.clearTasks();
      } else {
        print('Clearing todos from local database');
        await _local.clearTasks();
      }
    } catch (e) {
      print('Error clearing tasks: $e');
    }
  }
}
