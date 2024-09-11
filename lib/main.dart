import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/models/todo_screen.dart';
import 'package:todo_flutter/services/hive_service.dart'; // Import your Hive service
import 'package:todo_flutter/services/sqlite_service.dart'; // Import your SQLite service
import 'package:todo_flutter/services/remote_data_source.dart'; // Import your Remote data source
import 'package:todo_flutter/services/todo_data_source_factory.dart'; // Import the factory to create the data source
import 'firebase_options.dart'; // Ensure this path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized

  await Hive.initFlutter();
  Hive.registerAdapter(ToDoAdapter());
  await Hive.openBox<ToDo>('todos');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final dataSource = await ToDoDataSourceFactory.create();

  if (dataSource is HiveService) {
    print('Using Hive database for web.');
  } else if (dataSource is SQLiteService) {
    print('Using SQLite database for mobile.');
  } else if (dataSource is RemoteDataSource) {
    print('Using Firebase Realtime Database for remote.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}
