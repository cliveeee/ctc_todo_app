import 'package:flutter/material.dart';
import 'package:todo_flutter/models/todos.dart';
import 'package:todo_flutter/models/details_screen.dart'; // Import the DetailsScreen
import 'package:todo_flutter/services/todo_data_source_factory.dart'; // Adjust the import according to your file structure
import 'package:todo_flutter/services/todo_data_source.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ToDoDataSource? _remoteDataSource; // Updated to use ToDoDataSource
  List<ToDo> _tasks = [];
  ToDo? _editingTask;

  @override
  void initState() {
    super.initState();
    _initializeDataSource();
  }

  Future<void> _initializeDataSource() async {
    _remoteDataSource = await ToDoDataSourceFactory.create();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _remoteDataSource!.fetchTasks();
    setState(() {});
  }

  void _showTaskDialog({ToDo? task}) {
    if (task != null) {
      _editingTask = task;
      _titleController.text = task.name;
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
                  border: OutlineInputBorder(),
                  hintText: 'Enter title',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15.0),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
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
                  _editingTask!.name = title;
                  _editingTask!.description = description;
                  await _remoteDataSource!.updateTask(_editingTask!);
                } else {
                  final newTask = ToDo(
                    name: title,
                    description: description,
                    isCompleted: false,
                  );
                  await _remoteDataSource!.addTask(newTask);
                }

                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
                _loadTasks();
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

  Future<void> _clearAllTasks() async {
    await _remoteDataSource!.clearTasks();
    await _loadTasks();
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
        child: _tasks.isEmpty
            ? Center(
                child: Text(
                  'No tasks yet!',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[400],
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    color: Colors.grey[800],
                    child: ListTile(
                      leading: Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.red[500],
                        value: task.isCompleted,
                        onChanged: (bool? value) async {
                          task.isCompleted = value ?? false;
                          await _remoteDataSource!.updateTask(task);
                          _loadTasks();
                        },
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
                            onPressed: () {
                              _showTaskDialog(task: task);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever_rounded,
                                color: Colors.red),
                            onPressed: () async {
                              await _remoteDataSource!.deleteTask(task);
                              _loadTasks();
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to DetailsScreen when tapping the tile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(task: task),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
