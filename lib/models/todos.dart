import 'package:hive/hive.dart';

part 'todos.g.dart';

@HiveType(typeId: 0)
class ToDo extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  ToDo({
    this.id,
    required this.name,
    required this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory ToDo.fromMap(Map<dynamic, dynamic> map) {
    return ToDo(
      id: map['id'] as String?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isCompleted: (map['isCompleted'] is int)
          ? map['isCompleted'] == 1
          : (map['isCompleted'] is bool)
              ? map['isCompleted']
              : false,
    );
  }
}
