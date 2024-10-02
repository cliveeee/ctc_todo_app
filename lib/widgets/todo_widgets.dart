import 'package:flutter/material.dart';
import 'package:todo_flutter/models/todos.dart';

class TodoWidget extends StatelessWidget {
  final ToDo task;
  final Function(bool?)? onChanged;
  final Function()? onEdit;
  final Function()? onDelete;
  final VoidCallback? onTap;

  const TodoWidget({
    Key? key,
    required this.task,
    this.onChanged,
    this.onEdit,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        leading: Checkbox(
          checkColor: Colors.white,
          activeColor: Colors.red[500],
          value: task.isCompleted,
          onChanged: onChanged,
          side: const BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
        ),
        title: Text(
          task.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          task.description,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
