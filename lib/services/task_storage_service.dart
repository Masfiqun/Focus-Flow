import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

class TaskStorageService {
  static const String _boxName = 'focusflow_tasks';

  static Box<dynamic>? _box;

  /// Initializes Hive and opens the task storage box.
  static Future<void> init() async {
    await Hive.initFlutter();

    _box = await Hive.openBox<dynamic>(_boxName);
  }

  /// Makes sure the Hive box is available.
  static Box<dynamic> get _taskBox {
    final box = _box;

    if (box == null || !box.isOpen) {
      throw StateError(
        'TaskStorageService has not been initialized. '
        'Call TaskStorageService.init() before using it.',
      );
    }

    return box;
  }

  /// Returns all saved tasks.
  static List<Task> getTasks() {
    final tasks = <Task>[];

    for (final value in _taskBox.values) {
      if (value is Map) {
        try {
          tasks.add(Task.fromMap(value));
        } catch (_) {
          // Ignore invalid stored entries.
        }
      }
    }

    return tasks;
  }

  /// Saves a new task.
  static Future<void> saveTask(Task task) async {
    await _taskBox.put(
      task.id,
      task.toMap(),
    );
  }

  /// Updates an existing task.
  static Future<void> updateTask(Task task) async {
    await _taskBox.put(
      task.id,
      task.toMap(),
    );
  }

  /// Deletes a task.
  static Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }

  /// Deletes all saved tasks.
  static Future<void> clearTasks() async {
    await _taskBox.clear();
  }

  /// Returns the number of saved tasks.
  static int get taskCount {
    return _taskBox.length;
  }
}