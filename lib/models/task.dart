class Task {
  const Task({
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.duration,
  });

  final String title;
  final String category;
  final bool isCompleted;
  final int duration;
}
