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
}
