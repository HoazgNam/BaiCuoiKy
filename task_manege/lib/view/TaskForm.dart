import 'package:flutter/material.dart';
import '../model/MyTask.dart';
import '../api/UserAPIService.dart';
import '../model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskForm extends StatefulWidget {
  final MyTask? task;
  final Function(MyTask) onSave;

  const TaskForm({super.key, this.task, required this.onSave});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _attachmentsController = TextEditingController();

  final _statusList = ['open', 'in progress', 'review', 'completed'];
  final _priorityList = [3, 2, 1]; // Cao -> Trung bình -> Thấp

  DateTime? _dueDate;
  String _selectedStatus = 'open';
  int _selectedPriority = 2;
  String? _assignedTo;
  bool _isCompleted = false;

  List<User> _userList = [];
  String? _currentUserId;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('accountId');
    _currentUserRole = prefs.getString('role') ?? 'user';

    final allUsers = await UserAPIService.instance.getAllUsers();
    setState(() {
      _userList = allUsers.where((u) => u.role == 'user').toList();

      if (widget.task != null) {
        final t = widget.task!;
        _titleController.text = t.title;
        _descriptionController.text = t.description;
        _categoryController.text = t.category ?? '';
        _attachmentsController.text = t.attachments?.join(',') ?? '';
        _selectedStatus = t.status;
        _selectedPriority = t.priority;
        _dueDate = t.dueDate;
        _assignedTo = t.assignedTo;
        _isCompleted = t.completed;
      } else {
        _assignedTo = _currentUserRole == 'admin' ? null : _currentUserId;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _attachmentsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final task = MyTask(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      dueDate: _dueDate,
      createdAt: widget.task?.createdAt ?? now,
      updatedAt: now,
      createdBy: widget.task?.createdBy ?? _currentUserId!,
      assignedTo: _currentUserRole == 'admin' ? _assignedTo : _currentUserId,
      category: _categoryController.text.trim(),
      attachments: _attachmentsController.text.trim().split(','),
      completed: _isCompleted,
    );

    widget.onSave(task);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa công việc' : 'Tạo công việc mới'),
        backgroundColor: Colors.teal[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  labelStyle: TextStyle(color: Colors.teal),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  labelStyle: TextStyle(color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statusList.map((s) {
                  Color color;
                  switch (s) {
                    case 'open':
                      color = Colors.blue;
                      break;
                    case 'in progress':
                      color = Colors.deepOrange;
                      break;
                    case 'review':
                      color = Colors.purple;
                      break;
                    case 'completed':
                      color = Colors.green;
                      break;
                    default:
                      color = Colors.black;
                  }
                  return DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  labelStyle: TextStyle(color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedPriority,
                items: _priorityList.map((level) {
                  String text;
                  Color color;
                  switch (level) {
                    case 3:
                      text = 'Cao';
                      color = Colors.red;
                      break;
                    case 2:
                      text = 'Trung bình';
                      color = Colors.orange;
                      break;
                    case 1:
                      text = 'Thấp';
                      color = Colors.purple;
                      break;
                    default:
                      text = 'Không xác định';
                      color = Colors.black;
                  }
                  return DropdownMenuItem(
                    value: level,
                    child: Text(
                      text,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPriority = val!),
                decoration: const InputDecoration(
                  labelText: 'Độ ưu tiên',
                  labelStyle: TextStyle(color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Phân loại',
                  labelStyle: TextStyle(color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _attachmentsController,
                decoration: const InputDecoration(
                  labelText: 'Tệp đính kèm (dạng link, cách nhau bằng dấu phẩy)',
                  labelStyle: TextStyle(color: Colors.teal),
                ),
              ),
              const SizedBox(height: 12),
              if (_currentUserRole == 'admin') ...[
                _userList.isEmpty
                    ? const Text(
                  'Đang tải danh sách người dùng...',
                  style: TextStyle(color: Colors.grey),
                )
                    : DropdownButtonFormField<String>(
                  value: _assignedTo,
                  items: _userList.map((user) {
                    return DropdownMenuItem<String>(
                      value: user.id,
                      child: Text(user.username),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _assignedTo = val),
                  decoration: const InputDecoration(
                    labelText: 'Giao cho',
                    labelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ] else ...[
                TextFormField(
                  enabled: false,
                  initialValue: 'Bạn (${_currentUserId ?? "Không xác định"})',
                  decoration: const InputDecoration(
                    labelText: 'Giao cho',
                    labelStyle: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _dueDate == null
                      ? 'Chọn hạn chót'
                      : 'Hạn chót: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  style: const TextStyle(color: Colors.teal),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.teal),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Đánh dấu là hoàn thành'),
                value: _isCompleted,
                activeColor: Colors.teal,
                onChanged: (val) => setState(() => _isCompleted = val ?? false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style:
                ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                onPressed: _submit,
                child: Text(isEdit ? 'Cập nhật' : 'Tạo mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
