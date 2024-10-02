import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_flutter/providers/todo_provider.dart';
import 'package:todo_flutter/services/todo_data_source_factory.dart';
import 'package:todo_flutter/services/todo_data_source.dart';
import 'package:todo_flutter/models/todo_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final dataSource = await ToDoDataSourceFactory.create();

  runApp(MyApp(dataSource: dataSource));
}

class MyApp extends StatelessWidget {
  final ToDoDataSource dataSource;

  const MyApp({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(dataSource: dataSource),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TodoScreen(),
      ),
    );
  }
}
