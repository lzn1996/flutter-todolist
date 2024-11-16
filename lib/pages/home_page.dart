import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/shared_prefs.dart';
import '../widgets/task_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await SharedPrefs.loadTasks();
    setState(() {});
  }

  Future<void> _addTask(String title) async {
    if (title.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: title));
      });
      await SharedPrefs.saveTasks(_tasks);
      _controller.clear();
    }
  }

  Future<void> _toggleTask(int index) async {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    await SharedPrefs.saveTasks(_tasks);
  }

  Future<void> _deleteTask(int index) async {
    setState(() {
      _tasks.removeAt(index);
    });
    await SharedPrefs.saveTasks(_tasks);
  }

  Future<void> _editTask(int index, String newTitle) async {
    setState(() {
      _tasks[index].title = newTitle;
    });
    await SharedPrefs.saveTasks(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List usando "Shared Preferences"'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (value) => _addTask(value),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Digite uma tarefa',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTask(_controller.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: _tasks[index],
                  onToggle: () => _toggleTask(index),
                  onDelete: () => _deleteTask(index),
                  onEdit: (newTitle) => _editTask(index, newTitle),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}