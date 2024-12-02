import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> _confirmDeleteTask(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text("Você tem certeza que deseja excluir esta tarefa?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _tasks.removeAt(index);
      });
      await SharedPrefs.saveTasks(_tasks);
    }
  }

  Future<void> _editTask(int index, String newTitle) async {
    setState(() {
      _tasks[index].title = newTitle;
    });
    await SharedPrefs.saveTasks(_tasks);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Task task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
    SharedPrefs.saveTasks(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List usando "Shared Preferences"'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (value) => _addTask(value),
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite uma tarefa',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addTask(_controller.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma tarefa adicionada',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )
                : ReorderableListView(
                    onReorder: _reorderTasks,
                    children: [
                      for (int index = 0; index < _tasks.length; index++)
                        Padding(
                          key: ValueKey(_tasks[index]),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TaskItem(
                              task: _tasks[index],
                              onToggle: () => _toggleTask(index),
                              onDelete: () => _confirmDeleteTask(index),
                              onEdit: (newTitle) => _editTask(index, newTitle),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}