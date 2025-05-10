import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MyTask.dart';
import '../model/User.dart';
import '../api/TaskAPIService.dart';
import '../api/UserAPIService.dart';
import 'TaskForm.dart';
import 'TaskLoginScreen.dart';
import 'TaskDetailScreen.dart';
import 'TaskListItem.dart';

class TaskListScreen extends StatefulWidget {
  final Function? onLogout;

  const TaskListScreen({this.onLogout, Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<MyTask>> _tasksFuture;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTaskIds = {};
  List<MyTask> _allTasks = [];
  List<User> _userList = [];
  bool _selectionMode = false;
  String? _userId;
  String? _username;

  @override
  void initState() {
    super.initState();
    _tasksFuture = Future.value([]);
    _loadUserAndRefresh();
  }

  Future<void> _loadUserAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('accountId');
    _username = prefs.getString('username');
    _userList = await UserAPIService.instance.getAllUsers();
    if (mounted) {
      _refreshTasks();
    }
  }

  void _refreshTasks() {
    if (_userId != null) {
      setState(() {
        _tasksFuture = TaskAPIService.instance.getTasksByUser(_userId!).then((tasks) {
          _allTasks = tasks;
          return _filterTasks(_searchController.text);
        });
        _selectedTaskIds.clear();
        _selectionMode = false;
      });
    } else {
      _tasksFuture = Future.value([]);
    }
  }

  List<MyTask> _filterTasks(String query) {
    final lowerQuery = query.toLowerCase();
    return _allTasks.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
        if (_selectedTaskIds.isEmpty) _selectionMode = false;
      } else {
        _selectedTaskIds.add(taskId);
        _selectionMode = true;
      }
    });
  }

  void _deleteSelectedTasks() async {
    if (_selectedTaskIds.isNotEmpty) {
      for (final id in _selectedTaskIds) {
        try {
          await TaskAPIService.instance.deleteTask(id);
        } catch (e) {
          print("Error deleting task $id: $e");
        }
      }
      _refreshTasks();
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TaskLoginScreen()),
            (route) => false,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? 'Đã chọn: ${_selectedTaskIds.length}'
              : 'Xin chào, ${_username ?? 'người dùng'}',
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          if (_selectionMode)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteSelectedTasks)
          else ...[
            IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshTasks),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _showLogoutDialog();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Đăng xuất'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _tasksFuture = Future.value(_filterTasks(''));
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onChanged: (value) {
                setState(() {
                  _tasksFuture = Future.value(_filterTasks(value));
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<MyTask>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty && _userId != null) {
            return const Center(child: Text('Không có công việc'));
          }
          if (tasks.isEmpty && _userId == null) {
            return const Center(child: Text('Vui lòng đăng nhập để xem công việc.'));
          }

          final notes = snapshot.data!;
          notes.sort((a, b) => b.priority.compareTo(a.priority));

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isSelected = _selectedTaskIds.contains(task.id);
              return GestureDetector(
                onLongPress: () => _toggleSelection(task.id),
                child: Container(
                  color: isSelected ? Colors.grey[300] : null,
                  child: TaskListItem(
                    task: task,
                    userList: _userList,
                    onEdit: () async {
                      final updatedTask = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskForm(
                            task: task,
                            onSave: (updatedTask) async {
                              try {
                                await TaskAPIService.instance.updateTask(updatedTask);
                                if (mounted) Navigator.pop(context, updatedTask);
                              } catch (e) {
                                print("Error updating task: $e");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to update task. Please try again.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                          ),
                        ),
                      );
                      if (updatedTask != null && mounted) _refreshTasks();
                    },
                    onDelete: () async {
                      try {
                        await TaskAPIService.instance.deleteTask(task.id);
                        _refreshTasks();
                      } catch (e) {
                        print("Error deleting task: $e");
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete task. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    onTap: () {
                      if (_selectionMode) {
                        _toggleSelection(task.id);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(task: task, userList: _userList),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskForm(
                onSave: (task) async {
                  try {
                    await TaskAPIService.instance.createTask(task);
                    if (mounted) Navigator.pop(context, task);
                  } catch (e) {
                    print("Error creating task: $e");
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to create task. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
          );
          if (newTask != null && mounted) {
            _refreshTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
