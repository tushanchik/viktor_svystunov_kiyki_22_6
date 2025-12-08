class Task {
  String id;
  String title;
  bool isDone;
  bool isStarred;
  DateTime? dueDate;
  String categoryId;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.isStarred = false,
    this.dueDate,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
    'isStarred': isStarred,
    'dueDate': dueDate?.toIso8601String(),
    'categoryId': categoryId,
  };

  factory Task.fromJson(Map<String, dynamic> json, String id) {
    return Task(
      id: id,
      title: json['title'] ?? '',
      isDone: json['isDone'] ?? false,
      isStarred: json['isStarred'] ?? false,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'])
          : null,
      categoryId: json['categoryId'] ?? 'c4',
    );
  }
}
