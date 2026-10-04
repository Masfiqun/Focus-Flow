import 'package:hive_flutter/hive_flutter.dart';

import '../models/focus_session.dart';

class FocusSessionStorageService {
  static const String _boxName = 'focusflow_focus_sessions';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static Box<dynamic> get _sessionBox {
    final box = _box;

    if (box == null || !box.isOpen) {
      throw StateError(
        'FocusSessionStorageService has not been initialized. '
        'Call FocusSessionStorageService.init() before using it.',
      );
    }

    return box;
  }

  static List<FocusSession> getSessions() {
    final sessions = <FocusSession>[];

    for (final value in _sessionBox.values) {
      if (value is Map) {
        try {
          sessions.add(
            FocusSession.fromMap(value),
          );
        } catch (_) {
          // Ignore invalid stored records.
        }
      }
    }

    sessions.sort(
      (a, b) => b.startedAt.compareTo(a.startedAt),
    );

    return sessions;
  }

  static Future<void> saveSession(
    FocusSession session,
  ) async {
    await _sessionBox.put(
      session.id,
      session.toMap(),
    );
  }

  static Future<void> updateSession(
    FocusSession session,
  ) async {
    await _sessionBox.put(
      session.id,
      session.toMap(),
    );
  }

  static Future<void> deleteSession(
    String sessionId,
  ) async {
    await _sessionBox.delete(sessionId);
  }

  /// Returns all focus sessions associated with [taskId].
  ///
  /// Quick Focus sessions have a null taskId and are therefore
  /// never returned by this method.
  static List<FocusSession> getSessionsForTask(
    String taskId,
  ) {
    return getSessions()
        .where(
          (session) => session.taskId == taskId,
        )
        .toList();
  }

  /// Deletes every focus session associated with [taskId].
  ///
  /// Quick Focus sessions are preserved because their taskId is null.
  static Future<void> deleteSessionsForTask(
    String taskId,
  ) async {
    final sessionIds = <dynamic>[];

    for (final entry in _sessionBox.toMap().entries) {
      final value = entry.value;

      if (value is! Map) {
        continue;
      }

      try {
        final session = FocusSession.fromMap(value);

        if (session.taskId == taskId) {
          sessionIds.add(entry.key);
        }
      } catch (_) {
        // Ignore invalid stored records.
      }
    }

    if (sessionIds.isEmpty) {
      return;
    }

    await _sessionBox.deleteAll(
      sessionIds,
    );
  }

  /// Restores a collection of previously deleted sessions.
  static Future<void> restoreSessions(
    List<FocusSession> sessions,
  ) async {
    for (final session in sessions) {
      await saveSession(session);
    }
  }

  static Future<void> clearSessions() async {
    await _sessionBox.clear();
  }

  static FocusSession? getSession(
    String sessionId,
  ) {
    final value = _sessionBox.get(sessionId);

    if (value is! Map) {
      return null;
    }

    try {
      return FocusSession.fromMap(value);
    } catch (_) {
      return null;
    }
  }

  static int get sessionCount {
    return _sessionBox.length;
  }
}

