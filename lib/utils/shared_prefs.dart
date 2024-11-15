import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class SharedPrefs {
  static const String _key = 'tasks';

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonTasks = tasks.map((task) => task.toMap()).toList();
    prefs.setString(_key, jsonEncode(jsonTasks));
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return []; 
    final List<dynamic> jsonTasks = jsonDecode(jsonString);
    return jsonTasks.map((json) => Task.fromMap(json)).toList();
  }
}
