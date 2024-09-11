import 'package:hive/hive.dart';

part 'todos.g.dart';

@HiveType(typeId: 0)
class ToDo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  bool isCompleted;

  ToDo({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}
