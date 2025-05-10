import 'package:flutter/material.dart';
import '../model/User.dart';
import '../api/UserAPIService.dart';
import 'TaskLoginScreen.dart';

class TaskRegisterScreen extends StatefulWidget {
  const TaskRegisterScreen({Key? key}) : super(key: key);

  @override
  State<TaskRegisterScreen> createState() => _TaskRegisterScreenState();
}

class _TaskRegisterScreenState extends State<TaskRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final allUsers = await UserAPIService.instance.getAllUsers();

      // Kiểm tra trùng username hoặc email
      final isTaken = allUsers.any((u) =>
      u.username.trim().toLowerCase() == _usernameController.text.trim().toLowerCase() ||
          u.email.trim().toLowerCase() == _emailController.text.trim().toLowerCase());

      if (isTaken) {
        setState(() {
          _error = "Tên đăng nhập hoặc email đã được sử dụng.";
          _isLoading = false;
        });
        return;
      }

      int nextId = 20;
      if (allUsers.isNotEmpty) {
        final maxId = allUsers.map((u) => int.tryParse(u.id) ?? 0).reduce((a, b) => a > b ? a : b);
        nextId = maxId + 1;
      }

      final newUser = User(
        id: nextId.toString(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        role: 'user',
      );

      await UserAPIService.instance.createUser(newUser);

      setState(() {
        _success = "Đăng ký thành công! Vui lòng đăng nhập.";
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TaskLoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = "Đăng ký thất bại: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Đăng Ký", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: "Tên đăng nhập"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập tên đăng nhập";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập email";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return "Email không hợp lệ";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Mật khẩu"),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập mật khẩu";
                        }
                        if (value.length < 6) {
                          return "Mật khẩu phải có ít nhất 6 ký tự";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    if (_success != null)
                      Text(_success!, style: const TextStyle(color: Colors.green)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _register,
                      icon: const Icon(Icons.person_add),
                      label: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Tạo tài khoản"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
