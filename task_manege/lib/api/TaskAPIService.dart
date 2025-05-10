import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/MyTask.dart';

class TaskAPIService {
  static final TaskAPIService instance = TaskAPIService._init();
  final String baseUrl = 'http://192.168.1.15/task_maneger';
  TaskAPIService._init();

  Future<MyTask> createTask(MyTask task) async {
    final taskMap = {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'priority': task.priority,
      'dueDate': task.dueDate?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
      'createdBy': task.createdBy,
      'assignedTo': task.assignedTo,
      'category': task.category,
      'attachments': jsonEncode(task.attachments ?? []),
      'completed': task.completed ? 1 : 0,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/tasks.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taskMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MyTask.fromMap(jsonDecode(response.body));
    } else {
      print(' Server response: ${response.body}');
      throw Exception('Tạo task thất bại');
    }
  }

  Future<List<MyTask>> getAllTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MyTask.fromMap(e)).toList();
    } else {
      print(' Server response: ${response.body}');
      throw Exception('Không thể tải danh sách task');
    }
  }

  Future<MyTask> updateTask(MyTask task) async {
    final taskMap = {
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'priority': task.priority,
      'dueDate': task.dueDate?.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
      'createdBy': task.createdBy,
      'assignedTo': task.assignedTo,
      'category': task.category,
      'attachments': jsonEncode(task.attachments ?? []),
      'completed': task.completed ? 1 : 0,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/tasks.php?id=${task.id}&_method=PUT'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(taskMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final updated = jsonDecode(response.body);
      return MyTask.fromMap(updated);
    } else {
      print(' Server response: ${response.body}');
      throw Exception('Cập nhật task thất bại');
    }
  }

  Future<bool> deleteTask(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks.php?id=$id&_method=DELETE'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(' Server response: ${response.body}');
      return false;
    }
  }

  Future<List<MyTask>> getTasksByUser(String userId) async {
    final allTasks = await getAllTasks();
    return allTasks
        .where((task) =>
    task.createdBy == userId || task.assignedTo == userId)
        .toList();
  }
  Future<List<MyTask>> searchTasks(String userId, String keyword) async {
    final tasks = await getTasksByUser(userId);
    return tasks.where((task) {
      final lowerKeyword = keyword.toLowerCase();
      return task.title.toLowerCase().contains(lowerKeyword) ||
          task.description.toLowerCase().contains(lowerKeyword) ||
          (task.category ?? '').toLowerCase().contains(lowerKeyword);
    }).toList();
  }
}
