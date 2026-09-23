class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final int duration;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? duration,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      duration: (map['duration'] as num).toInt(),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}