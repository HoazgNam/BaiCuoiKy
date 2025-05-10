import 'package:flutter/material.dart';
import 'package:task_manege/view/TaskListScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manege/view/TaskLoginScreen.dart';
import 'package:task_manege/view/TaskListScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _AuthCheckWidget(),
    );
  }
}

class _AuthCheckWidget extends StatelessWidget {
  const _AuthCheckWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) return TaskLoginScreen ();

        final prefs = snapshot.data!;
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (isLoggedIn) {
          return TaskListScreen(
            onLogout: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              runApp(const MyApp());
            },
          );
        } else {
          return TaskLoginScreen ();
        }
      },
    );
  }
}
