class FocusSession {
  final String id;
  final String? taskId;
  final String taskTitle;

  /// Planned duration in seconds.
  final int durationSeconds;

  /// Actual focused duration in seconds.
  final int completedSeconds;

  final DateTime startedAt;
  final DateTime? completedAt;

  const FocusSession({
    required this.id,
    this.taskId,
    required this.taskTitle,
    required this.durationSeconds,
    required this.completedSeconds,
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted {
    return completedSeconds >= durationSeconds;
  }

  double get progress {
    if (durationSeconds <= 0) {
      return 0;
    }

    return (completedSeconds / durationSeconds)
        .clamp(0.0, 1.0);
  }

  int get durationMinutes {
    return durationSeconds ~/ 60;
  }

  int get completedMinutes {
    return completedSeconds ~/ 60;
  }

  FocusSession copyWith({
    String? id,
    String? taskId,
    String? taskTitle,
    int? durationSeconds,
    int? completedSeconds,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      durationSeconds:
          durationSeconds ?? this.durationSeconds,
      completedSeconds:
          completedSeconds ?? this.completedSeconds,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'durationSeconds': durationSeconds,
      'completedSeconds': completedSeconds,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory FocusSession.fromMap(
    Map<dynamic, dynamic> map,
  ) {
    // Supports the previous version of the model too.
    final int durationSeconds =
        map['durationSeconds'] != null
            ? (map['durationSeconds'] as num).toInt()
            : ((map['duration'] as num?)?.toInt() ?? 0) * 60;

    final int completedSeconds =
        map['completedSeconds'] != null
            ? (map['completedSeconds'] as num).toInt()
            : ((map['completedDuration'] as num?)
                        ?.toInt() ??
                    0) *
                60;

    return FocusSession(
      id: map['id'] as String,
      taskId: map['taskId'] as String?,
      taskTitle: map['taskTitle'] as String,
      durationSeconds: durationSeconds,
      completedSeconds: completedSeconds,
      startedAt: DateTime.parse(
        map['startedAt'] as String,
      ),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.parse(
              map['completedAt'] as String,
            ),
    );
  }
}