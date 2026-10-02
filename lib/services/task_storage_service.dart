import 'package:hive_flutter/hive_flutter.dart';

import '../models/task.dart';

class TaskStorageService {
  static const String _boxName = 'focusflow_tasks';

  // Metadata key used to remember that the initial tasks
  // have already been created once.
  static const String _initialTasksCreatedKey =
      '__initial_tasks_created__';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();

    _box = await Hive.openBox<dynamic>(_boxName);

    // Migration/support for existing installations:
    //
    // If tasks already exist from an older version of FocusFlow,
    // consider the initial setup already completed.
    if (_box!.get(_initialTasksCreatedKey) != true) {
      final hasExistingTasks = _box!.values.any(
        (value) => value is Map,
      );

      if (hasExistingTasks) {
        await _box!.put(
          _initialTasksCreatedKey,
          true,
        );
      }
    }
  }

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

  // ---------------------------------------------------------------------------
  // INITIAL TASK SETUP
  // ---------------------------------------------------------------------------

  static bool get initialTasksCreated {
    return _taskBox.get(
          _initialTasksCreatedKey,
        ) ==
        true;
  }

  static Future<void> markInitialTasksCreated() async {
    await _taskBox.put(
      _initialTasksCreatedKey,
      true,
    );
  }

  // ---------------------------------------------------------------------------
  // TASKS
  // ---------------------------------------------------------------------------

  static List<Task> getTasks() {
    final tasks = <Task>[];

    for (final value in _taskBox.values) {
      // Ignore metadata values.
      if (value is Map) {
        try {
          tasks.add(
            Task.fromMap(value),
          );
        } catch (_) {
          // Ignore invalid entries instead of crashing the app.
        }
      }
    }

    return tasks;
  }

  static Future<void> saveTask(Task task) async {
    await _taskBox.put(
      task.id,
      task.toMap(),
    );
  }

  static Future<void> updateTask(Task task) async {
    await _taskBox.put(
      task.id,
      task.toMap(),
    );
  }

  static Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }

  static Future<void> clearTasks() async {
    // Only delete actual task entries.
    //
    // Do NOT clear the entire Hive box because the
    // initial-task flag must survive.
    final taskIds = <dynamic>[];

    for (final entry in _taskBox.toMap().entries) {
      if (entry.key != _initialTasksCreatedKey &&
          entry.value is Map) {
        taskIds.add(entry.key);
      }
    }

    if (taskIds.isEmpty) {
      return;
    }

    await _taskBox.deleteAll(taskIds);
  }

  static int get taskCount {
    return getTasks().length;
  }
}