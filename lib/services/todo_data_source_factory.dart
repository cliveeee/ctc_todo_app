import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart'; // Add this import
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/hive_service.dart';
import 'package:todo_flutter/services/sqlite_service.dart';
import 'package:todo_flutter/services/remote_data_source.dart';
import 'package:todo_flutter/services/todo_data_source.dart';

class ToDoDataSourceFactory {
  static ToDoDataSource? _instance;

  static Future<ToDoDataSource> create() async {
    if (_instance != null) {
      return _instance!;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // There is an internet connection
      print('Using RemoteDatabase (Firebase)');
      _instance = RemoteDataSource();
    } else {
      // No internet connection
      if (kIsWeb) {
        var box = await Hive.openBox<ToDo>('todos');
        print('Using Hive database for web');
        _instance = HiveService(box);
      } else if (Platform.isAndroid || Platform.isIOS) {
        print('Using SQLite database for mobile');
        _instance = SQLiteService();
      } else {
        throw Exception('Unsupported platform');
      }
    }

    return _instance!;
  }
}
