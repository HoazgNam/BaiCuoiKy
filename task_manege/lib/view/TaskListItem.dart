import 'package:flutter/material.dart';
import '../model/MyTask.dart';
import '../model/User.dart';
import 'TaskDetailScreen.dart';

class TaskListItem extends StatelessWidget {
  final MyTask task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onTap;
  final List<User> userList;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    required this.userList,
    this.onTap,
  }) : super(key: key);

  Color _priorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.teal.shade100;
      case 2:
        return Colors.pink.shade100;
      default:
        return Colors.amber.shade100;
    }
  }

  Color _textColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _priorityColor(task.priority);
    final textColor = _textColor(bgColor);

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            task.title.isNotEmpty ? task.title[0].toUpperCase() : '?',
            style: TextStyle(color: bgColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(task.title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        subtitle: Text(
          task.description.length > 50
              ? '${task.description.substring(0, 50)}...'
              : task.description,
          style: TextStyle(color: textColor.withAlpha(200)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.cyan.shade600,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.deepOrange.shade700,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Xác nhận xoá'),
                    content: const Text('Bạn có chắc muốn xoá công việc này không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Huỷ'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Xoá'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task, userList: userList),
            ),
          );
        },
      ),
    );
  }
}
