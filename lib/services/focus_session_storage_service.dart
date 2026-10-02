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