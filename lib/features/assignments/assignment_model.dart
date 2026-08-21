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

  /// Returns the number of whole days between today and the due date.
  int get daysUntilDue {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final DateTime due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return due.difference(today).inDays;
  }

  /// Returns true when the assignment deadline has passed
  /// and the assignment is not completed.
  bool get isOverdue {
    return daysUntilDue < 0 && !isCompleted;
  }

  /// Returns a human-readable description of the deadline.
  String get dueDateLabel {
    if (isCompleted) {
      return 'Completed';
    }

    if (daysUntilDue < 0) {
      final int daysOverdue = daysUntilDue.abs();

      if (daysOverdue == 1) {
        return '1 day overdue';
      }

      return '$daysOverdue days overdue';
    }

    if (daysUntilDue == 0) {
      return 'Due today';
    }

    if (daysUntilDue == 1) {
      return 'Due tomorrow';
    }

    return 'Due in $daysUntilDue days';
  }

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
