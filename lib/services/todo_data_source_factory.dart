import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/services/hive_service.dart';
import 'package:todo_flutter/services/sqlite_service.dart';
import 'package:todo_flutter/services/remote_data_source.dart';
import 'package:todo_flutter/services/todo_data_source.dart';

class ToDoDataSourceFactory {
  static Future<ToDoDataSource> create() async {
    if (kIsWeb) {
      var box = await Hive.openBox<ToDo>('todos');
      print('Using Hive database for web');
      return HiveService(box);
    } else if (Platform.isAndroid || Platform.isIOS) {
      print('Using SQLite database for mobile');
      return SQLiteService();
    } else {
      print('Using RemoteDatabase (Firebase) for other platforms');
      return RemoteDataSource();
    }
  }
}
