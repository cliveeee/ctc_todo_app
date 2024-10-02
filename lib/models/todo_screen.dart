import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_flutter/providers/todo_provider.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/models/details_screen.dart';
import 'package:todo_flutter/widgets/todo_widgets.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).loadTasks();
    });
  }

  void _showTaskDialog(BuildContext context, {ToDo? task}) {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    if (task != null) {
      _titleController.text = task.name;
      _descriptionController.text = task.description;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          task == null ? 'Add Task' : 'Edit Task',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  hintText: 'Enter title',
                  hintStyle: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter description',
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            color: Colors.white,
            onPressed: () {
              final title = _titleController.text.trim();
              final description = _descriptionController.text.trim();

              if (title.isNotEmpty && description.isNotEmpty) {
                if (task == null) {
                  provider.addTask(ToDo(
                    name: title,
                    description: description,
                    isCompleted: false,
                  ));
                } else {
                  task.name = title;
                  task.description = description;
                  provider.updateTask(task);
                }

                Navigator.of(context).pop();
              }
            },
            child: Text(task == null ? 'Add' : 'Update'),
          ),
          MaterialButton(
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false).clearAllTasks();
            },
            color: Colors.red[500],
            iconSize: 35.0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.tasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks yet!',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[400],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: todoProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = todoProvider.tasks[index];
              return TodoWidget(
                task: task,
                onChanged: (bool? value) {
                  todoProvider.toggleTaskCompletion(task, value);
                },
                onEdit: () {
                  _showTaskDialog(context, task: task);
                },
                onDelete: () {
                  todoProvider.deleteTask(task);
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(task: task),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
