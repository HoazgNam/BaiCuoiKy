import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import '../model/User.dart';

class UserAPIService {
  static final UserAPIService instance = UserAPIService._init();
  final String baseUrl = 'http://192.168.1.15/task_maneger';
  UserAPIService._init();

  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users.php'),
      headers: {'Content-Type': 'application/json'},
      body: user.toJSON(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Tạo tài khoản thất bại: ${response.body}');
    }
  }

  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromMap(json)).toList();
    } else {
      throw Exception('Tải danh sách người dùng thất bại: ${response.statusCode}');
    }
  }

  Future<User?> getUserById(String id) async {
    final users = await getAllUsers();
    return users.firstWhereOrNull((u) => u.id == id);
  }

  Future<User?> login(String username, String password) async {
    final users = await getAllUsers();
    return users.firstWhereOrNull(
          (u) =>
      u.username.toLowerCase() == username.toLowerCase() &&
          u.password == password,
    );
  }

  Future<User> updateUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users.php?id=${user.id}&_method=PUT'),
      headers: {'Content-Type': 'application/json'},
      body: user.toJSON(),
    );

    if (response.statusCode == 200) {
      return user;
    } else {
      throw Exception('Cập nhật thất bại: ${response.body}');
    }
  }

  Future<bool> deleteUser(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users.php?id=$id&_method=DELETE'),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
