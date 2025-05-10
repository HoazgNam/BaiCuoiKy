import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/MyTask.dart';
import '../model/User.dart';

class TaskDetailScreen extends StatelessWidget {
  final MyTask task;
  final List<User> userList;

  const TaskDetailScreen({super.key, required this.task, required this.userList});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final userMap = {for (var u in userList) u.id: u};
    final creatorName = userMap[task.createdBy]?.username ?? task.createdBy;
    final assigneeName = userMap[task.assignedTo]?.username ?? 'Chưa có';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Text(task.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _infoRow(Icons.calendar_today, 'Tạo lúc: ${formatter.format(task.createdAt)}'),
              _infoRow(Icons.update, 'Cập nhật: ${formatter.format(task.updatedAt)}'),
              _infoRow(Icons.info_outline, 'Trạng thái: ${task.status}'),
              _infoRow(Icons.priority_high, 'Ưu tiên: ${_priorityText(task.priority)}', color: _priorityColor(task.priority)),
              if (task.dueDate != null) _infoRow(Icons.calendar_month, 'Hạn chót: ${formatter.format(task.dueDate!)}'),
              _infoRow(Icons.check_circle_outline, 'Hoàn thành: ${task.completed ? "✔ Có" : "✘ Chưa"}'),
              const SizedBox(height: 16),
              Text(task.description, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              if (task.category != null && task.category!.isNotEmpty) Chip(label: Text(task.category!)),
              const SizedBox(height: 20),
              Text('Người tạo: $creatorName'),
              Text('Giao cho: $assigneeName'),
              const SizedBox(height: 20),
              if (task.attachments != null && task.attachments!.isNotEmpty) ...[
                const Text('Tệp đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: task.attachments!.map((file) => Text('- $file')).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) => Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(fontSize: 16, color: color)),
    ],
  );

  String _priorityText(int value) => value == 1 ? 'Thấp' : value == 2 ? 'Trung bình' : 'Cao';
  Color _priorityColor(int value) => value == 3 ? Colors.red : value == 2 ? Colors.orange : Colors.green;
}
