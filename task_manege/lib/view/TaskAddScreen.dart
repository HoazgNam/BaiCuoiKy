import 'package:flutter/material.dart';
import '../model/MyTask.dart';
import '../api/TaskAPIService.dart';
import 'TaskForm.dart';

class TaskAddScreen extends StatelessWidget {
  const TaskAddScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TaskForm(
      onSave: (task) async {
        await TaskAPIService.instance.createTask(task);
        Navigator.pop(context, task);
      },
    );
  }
}