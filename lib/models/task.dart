class Task {
  String title;
  bool isDone;
  bool isStarred;
  DateTime? dueDate;

  Task({
    required this.title,
    this.isDone = false,
    this.isStarred = false,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
    'isStarred': isStarred,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      isDone: json['isDone'] ?? false,
      isStarred: json['isStarred'] ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'])
          : null,
    );
  }
}
