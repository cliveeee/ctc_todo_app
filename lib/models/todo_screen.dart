import 'package:flutter/material.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/models/details_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Box<ToDo> tasksBox;
  ToDo? _editingTask;

  @override
  void initState() {
    super.initState();
    tasksBox = Hive.box<ToDo>('todos');
  }

  void _showTaskDialog({ToDo? task}) {
    if (task != null) {
      _editingTask = task;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
    } else {
      _editingTask = null;
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
        contentPadding: const EdgeInsets.all(24.0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintText: 'Enter title',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintText: 'Enter description',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            color: Colors.white,
            onPressed: () async {
              final title = _titleController.text.trim();
              final description = _descriptionController.text.trim();

              if (title.isEmpty || description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        const Text('Both title and description are required.'),
                    backgroundColor: Colors.grey[800],
                  ),
                );
              } else {
                if (_editingTask != null) {
                  _editingTask!.title = title;
                  _editingTask!.description = description;
                  await _editingTask!.save();
                } else {
                  final newTask = ToDo(
                    title: title,
                    description: description,
                    isCompleted: false,
                  );
                  await tasksBox.add(newTask);
                }

                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
                setState(() {});
              }
            },
            child: Text(task == null ? 'Add' : 'Update'),
          ),
          MaterialButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _clearAllTasks() async {
    await tasksBox.clear();
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
            onPressed: _clearAllTasks,
            color: Colors.red[500],
            iconSize: 35.0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        backgroundColor: Colors.grey[800],
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ValueListenableBuilder(
          valueListenable: tasksBox.listenable(),
          builder: (context, Box<ToDo> box, _) {
            if (box.values.isEmpty) {
              return Center(
                child: Text(
                  'No tasks yet!',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[800],
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: box.values.length,
              itemBuilder: (context, index) {
                ToDo task = box.getAt(index)!;
                return Column(
                  children: [
                    Card(
                      color: Colors.grey[800],
                      child: ListTile(
                        leading: Checkbox(
                          checkColor: Colors.white,
                          activeColor: Colors.red[500],
                          value: task.isCompleted,
                          onChanged: (bool? value) {
                            task.isCompleted = value!;
                            task.save();
                          },
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 35.0,
                              color: Colors.blue[500],
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showTaskDialog(task: task),
                            ),
                            IconButton(
                              iconSize: 38.0,
                              color: Colors.red[500],
                              icon: const Icon(Icons.delete_forever_rounded),
                              onPressed: () {
                                task.delete();
                              },
                            ),
                          ],
                        ),
                        title: Text(
                          task.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsScreen(task: task),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5.0),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
