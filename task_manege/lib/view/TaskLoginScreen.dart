import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/User.dart';
import '../api/UserAPIService.dart';
import 'TaskListScreen.dart';
import 'TaskRegisterScreen.dart';

class TaskLoginScreen extends StatefulWidget {
  const TaskLoginScreen({super.key});

  @override
  _TaskLoginScreenState createState() => _TaskLoginScreenState();
}

class _TaskLoginScreenState extends State<TaskLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await UserAPIService.instance.login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

        setState(() => _isLoading = false);

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accountId', user.id);
          await prefs.setString('username', user.username);
          await prefs.setString('role', user.role); // Thêm dòng này để lưu role
          await prefs.setBool('isLoggedIn', true);

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => TaskListScreen(onLogout: _logout),
            ),
          );
        } else {
          _showErrorDialog('Đăng nhập thất bại', 'Sai tài khoản hoặc mật khẩu.');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog('Lỗi đăng nhập', 'Đã xảy ra lỗi: $e');
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TaskLoginScreen()),
            (route) => false,
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đăng nhập',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_box, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 40),
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.deepPurple),
                decoration: InputDecoration(
                  labelText: 'Tên đăng nhập',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.orangeAccent),
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.deepPurple),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  labelStyle: const TextStyle(color: Colors.deepPurple),
                  prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.orangeAccent),
                  ),
                  errorStyle: const TextStyle(color: Colors.red),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TaskRegisterScreen()),
                  );
                },
                child: const Text(
                  "Bạn chưa có tài khoản? Đăng ký",
                  style: TextStyle(color: Colors.deepOrange, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
