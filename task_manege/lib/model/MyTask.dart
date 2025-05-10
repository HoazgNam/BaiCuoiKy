import 'dart:convert';

class MyTask {
  String id;
  String title;
  String description;
  String status;
  int priority;
  DateTime? dueDate;
  DateTime createdAt;
  DateTime updatedAt;
  String createdBy;
  String? assignedTo;
  String? category;
  List<String>? attachments;
  bool completed;

  MyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.assignedTo,
    this.category,
    this.attachments,
    this.completed = false,
  });

  Map<String, dynamic> toData() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo ?? 'unknown',
      'category': category ?? 'Chưa phân loại',
      'attachments': attachments?.join(','),
      'completed': completed ? 1 : 0,
    };
  }

  Map<String, dynamic> toMap() => toData();

  String toJSON() => jsonEncode(toData());

  factory MyTask.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(String? value) {
      if (value == null || value.isEmpty) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return MyTask(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'To do',
      priority: map['priority'] is int
          ? map['priority']
          : int.tryParse(map['priority'].toString()) ?? 2,
      dueDate: parseDate(map['dueDate']?.toString()),
      createdAt: parseDate(map['createdAt']?.toString()) ?? DateTime.now(),
      updatedAt: parseDate(map['updatedAt']?.toString()) ?? DateTime.now(),
      createdBy: map['createdBy']?.toString() ?? '',
      assignedTo: map['assignedTo']?.toString(),
      category: map['category']?.toString(),
      attachments: map['attachments'] != null
          ? (map['attachments'] is List
          ? List<String>.from(map['attachments'])
          : List<String>.from((map['attachments'] as String).split(',')))
          : [],
      completed: map['completed'] == true ||
          map['completed'] == 1 ||
          map['completed']?.toString() == '1',
    );
  }

  factory MyTask.fromJSON(String json) => MyTask.fromMap(jsonDecode(json));

  MyTask copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    int? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? assignedTo,
    String? category,
    List<String>? attachments,
    bool? completed,
  }) {
    return MyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
      completed: completed ?? this.completed,
    );
  }

  @override
  String toString() {
    return 'MyTask(id: $id, title: $title, priority: $priority, completed: $completed)';
  }
}
