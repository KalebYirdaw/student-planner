class Assignment {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DateTime dueDate;
  final String priority;
  final int progress;
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.progress,
    required this.isCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'progress': progress,
      'isCompleted': isCompleted,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: json['priority'] as String,
      progress: json['progress'] as int,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
