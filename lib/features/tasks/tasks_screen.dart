import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/notification_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // ============================================================
  // LOCAL STORAGE
  // ============================================================

  static const String _tasksStorageKey = 'student_planner_tasks';

  // ============================================================
  // DEFAULT TASKS
  // ============================================================

  final List<Map<String, dynamic>> _defaultTasks = [
    {
      'title': 'Programming Assignment',
      'subject': 'Programming',
      'due': 'Friday',
      'dueDate': null,
      'reminder': 'None',
      'priority': 'High',
      'completed': false,
      'notificationId': null,
    },
    {
      'title': 'Database Test',
      'subject': 'Database Systems',
      'due': 'Next Monday',
      'dueDate': null,
      'reminder': 'None',
      'priority': 'Medium',
      'completed': false,
      'notificationId': null,
    },
  ];

  // ============================================================
  // TASK DATA
  // ============================================================

  List<Map<String, dynamic>> _tasks = [];

  bool _isLoading = true;

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadTasks();
  }

  // ============================================================
  // LOAD TASKS
  // ============================================================

  Future<void> _loadTasks() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedTasks = preferences.getString(_tasksStorageKey);

      if (savedTasks == null || savedTasks.trim().isEmpty) {
        _tasks = _defaultTasks
            .map((task) => Map<String, dynamic>.from(task))
            .toList();

        await _saveTasks();
      } else {
        final decodedTasks = jsonDecode(savedTasks);

        if (decodedTasks is List) {
          _tasks = decodedTasks
              .whereType<Map>()
              .map(
                (task) => Map<String, dynamic>.from(
                  task.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList();

          // Add fields introduced in newer versions.
          for (final task in _tasks) {
            task.putIfAbsent('dueDate', () => null);

            task.putIfAbsent('reminder', () => 'None');

            task.putIfAbsent('due', () => 'No date');

            task.putIfAbsent('priority', () => 'Medium');

            task.putIfAbsent('completed', () => false);

            task.putIfAbsent('notificationId', () => null);
          }

          await _saveTasks();
        } else {
          _tasks = _defaultTasks
              .map((task) => Map<String, dynamic>.from(task))
              .toList();

          await _saveTasks();
        }
      }
    } catch (_) {
      _tasks = _defaultTasks
          .map((task) => Map<String, dynamic>.from(task))
          .toList();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ============================================================
  // SAVE TASKS
  // ============================================================

  Future<void> _saveTasks() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final encodedTasks = jsonEncode(_tasks);

      await preferences.setString(_tasksStorageKey, encodedTasks);
    } catch (_) {
      // Keep the app functional if local storage fails.
    }
  }

  // ============================================================
  // GENERATE NOTIFICATION ID
  // ============================================================

  int _generateNotificationId() {
    return DateTime.now().microsecondsSinceEpoch.remainder(2147483647);
  }

  // ============================================================
  // ADD TASK
  // ============================================================

  Future<void> _addTask() async {
    if (!mounted) {
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TaskDialog(),
    );

    if (!mounted || result == null) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted) {
      return;
    }

    final title = result['title']?.toString() ?? '';

    final subject = result['subject']?.toString() ?? 'General';

    final DateTime? dueDate = result['dueDate'] as DateTime?;

    final reminder = result['reminder']?.toString() ?? 'None';

    final notificationId = _generateNotificationId();

    final newTask = <String, dynamic>{
      'title': title,
      'subject': subject,
      'due': dueDate == null ? 'No date' : _formatDateTime(dueDate),
      'dueDate': dueDate?.toIso8601String(),
      'reminder': reminder,
      'priority': 'Medium',
      'completed': false,
      'notificationId': notificationId,
    };

    setState(() {
      _tasks.add(newTask);
    });

    await _saveTasks();

    // Schedule reminder.
    if (dueDate != null && reminder != 'None') {
      await _scheduleTaskReminder(task: newTask);
    }

    if (!mounted) {
      return;
    }

    _showMessage(
      reminder == 'None'
          ? 'Task added successfully.'
          : 'Task added and reminder scheduled.',
    );
  }

  // ============================================================
  // SCHEDULE TASK REMINDER
  // ============================================================

  Future<void> _scheduleTaskReminder({
    required Map<String, dynamic> task,
  }) async {
    final dueDateString = task['dueDate']?.toString();

    if (dueDateString == null || dueDateString.isEmpty) {
      return;
    }

    final dueDate = DateTime.tryParse(dueDateString);

    if (dueDate == null) {
      return;
    }

    final reminder = task['reminder']?.toString() ?? 'None';

    final title = task['title']?.toString() ?? 'Task';

    final subject = task['subject']?.toString() ?? 'General';

    final notificationId = task['notificationId'] as int?;

    if (notificationId == null) {
      return;
    }

    DateTime notificationTime = dueDate;

    switch (reminder) {
      case '15 minutes before':
        notificationTime = dueDate.subtract(const Duration(minutes: 15));
        break;

      case '30 minutes before':
        notificationTime = dueDate.subtract(const Duration(minutes: 30));
        break;

      case '1 hour before':
        notificationTime = dueDate.subtract(const Duration(hours: 1));
        break;

      case '1 day before':
        notificationTime = dueDate.subtract(const Duration(days: 1));
        break;

      case 'None':
        return;
    }

    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('Reminder is already in the past.');

      return;
    }

    await NotificationService.instance.scheduleNotification(
      id: notificationId,
      title: 'Task Reminder',
      body: '$title • $subject',
      scheduledDate: notificationTime,
    );
  }

  // ============================================================
  // CANCEL TASK REMINDER
  // ============================================================

  Future<void> _cancelTaskReminder(Map<String, dynamic> task) async {
    final notificationId = task['notificationId'] as int?;

    if (notificationId == null) {
      return;
    }

    await NotificationService.instance.cancelNotification(notificationId);
  }

  // ============================================================
  // TOGGLE TASK
  // ============================================================

  Future<void> _toggleTask(int index) async {
    if (index < 0 || index >= _tasks.length) {
      return;
    }

    final task = _tasks[index];

    final currentValue = task['completed'] == true;

    if (currentValue) {
      // --------------------------------------------------------
      // TASK IS BEING MARKED INCOMPLETE
      // --------------------------------------------------------

      setState(() {
        task['completed'] = false;
      });

      await _saveTasks();

      final reminder = task['reminder']?.toString() ?? 'None';

      if (reminder != 'None') {
        await _scheduleTaskReminder(task: task);
      }

      if (mounted) {
        _showMessage('Task marked as incomplete.');
      }
    } else {
      // --------------------------------------------------------
      // TASK IS BEING COMPLETED
      // --------------------------------------------------------

      await _cancelTaskReminder(task);

      setState(() {
        task['completed'] = true;
      });

      await _saveTasks();

      if (mounted) {
        _showMessage('Task completed. Reminder cancelled.');
      }
    }
  }

  // ============================================================
  // DELETE TASK
  // ============================================================

  Future<void> _deleteTask(int index) async {
    if (index < 0 || index >= _tasks.length) {
      return;
    }

    final task = _tasks[index];

    final taskTitle = task['title']?.toString() ?? 'this task';

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "$taskTitle"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldDelete != true) {
      return;
    }

    if (index >= _tasks.length) {
      return;
    }

    // Cancel reminder before deleting.
    await _cancelTaskReminder(task);

    setState(() {
      _tasks.removeAt(index);
    });

    await _saveTasks();

    if (!mounted) {
      return;
    }

    _showMessage('Task deleted.');
  }

  // ============================================================
  // EDIT TASK
  // ============================================================

  Future<void> _editTask(int index) async {
    if (index < 0 || index >= _tasks.length) {
      return;
    }

    final originalTask = _tasks[index];

    final dueDateString = originalTask['dueDate']?.toString();

    DateTime? existingDueDate;

    if (dueDateString != null && dueDateString.isNotEmpty) {
      existingDueDate = DateTime.tryParse(dueDateString);
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TaskDialog(
        existingTitle: originalTask['title']?.toString(),
        existingSubject: originalTask['subject']?.toString(),
        existingDueDate: existingDueDate,
        existingReminder: originalTask['reminder']?.toString(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    // Cancel old reminder first.
    await _cancelTaskReminder(originalTask);

    final title = result['title']?.toString() ?? '';

    final subject = result['subject']?.toString() ?? 'General';

    final DateTime? dueDate = result['dueDate'] as DateTime?;

    final reminder = result['reminder']?.toString() ?? 'None';

    final notificationId =
        originalTask['notificationId'] as int? ?? _generateNotificationId();

    final updatedTask = <String, dynamic>{
      'title': title,
      'subject': subject,
      'due': dueDate == null ? 'No date' : _formatDateTime(dueDate),
      'dueDate': dueDate?.toIso8601String(),
      'reminder': reminder,
      'priority': originalTask['priority'] ?? 'Medium',
      'completed': originalTask['completed'] == true,
      'notificationId': notificationId,
    };

    setState(() {
      _tasks[index] = updatedTask;
    });

    await _saveTasks();

    // Only schedule if task isn't completed.
    if (updatedTask['completed'] != true &&
        dueDate != null &&
        reminder != 'None') {
      await _scheduleTaskReminder(task: updatedTask);
    }

    if (!mounted) {
      return;
    }

    _showMessage('Task updated successfully.');
  }

  // ============================================================
  // FORMAT DATE AND TIME
  // ============================================================

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.maybeOf(context);

      if (messenger == null) {
        return;
      }

      messenger.hideCurrentSnackBar();

      messenger.showSnackBar(SnackBar(content: Text(message)));
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final completedTasks = _tasks
        .where((task) => task['completed'] == true)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),

      // ========================================================
      // BODY
      // ========================================================
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet.\n'
                'Tap + to add your first task.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ==================================================
                // TASK PROGRESS
                // ==================================================
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Task Progress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$completedTasks of '
                                '${_tasks.length} '
                                'tasks completed',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TASK HEADER
                // ==================================================
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your Tasks',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${_tasks.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // TASK LIST
                // ==================================================
                ...List.generate(_tasks.length, (index) {
                  final task = _tasks[index];

                  final title = task['title']?.toString() ?? '';

                  final subject = task['subject']?.toString() ?? 'General';

                  final due = task['due']?.toString() ?? 'No date';

                  final priority = task['priority']?.toString() ?? 'Medium';

                  final reminder = task['reminder']?.toString() ?? 'None';

                  final completed = task['completed'] == true;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      // ========================================
                      // CHECKBOX
                      // ========================================
                      leading: Checkbox(
                        value: completed,
                        onChanged: (_) {
                          _toggleTask(index);
                        },
                      ),

                      // ========================================
                      // TASK TITLE
                      // ========================================
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),

                      // ========================================
                      // TASK DETAILS
                      // ========================================
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$subject • Due $due'),
                          if (reminder != 'None') ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.notifications_none, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  reminder,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // ========================================
                      // OPTIONS
                      // ========================================
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Task options',
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editTask(index);
                          }

                          if (value == 'delete') {
                            _deleteTask(index);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem<String>(
                              enabled: false,
                              child: Text('Priority: $priority'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),

      // ==========================================================
      // ADD TASK BUTTON
      // ==========================================================
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================
// TASK DIALOG
// ============================================================

class _TaskDialog extends StatefulWidget {
  const _TaskDialog({
    this.existingTitle,
    this.existingSubject,
    this.existingDueDate,
    this.existingReminder,
  });

  final String? existingTitle;

  final String? existingSubject;

  final DateTime? existingDueDate;

  final String? existingReminder;

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  late final TextEditingController _titleController;

  late final TextEditingController _subjectController;

  // ==========================================================
  // STATE
  // ==========================================================

  DateTime? _selectedDateTime;

  late String _selectedReminder;

  String? _errorMessage;

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.existingTitle ?? '');

    _subjectController = TextEditingController(
      text: widget.existingSubject ?? '',
    );

    _selectedDateTime = widget.existingDueDate;

    _selectedReminder = widget.existingReminder ?? 'None';
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _titleController.dispose();

    _subjectController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SELECT DATE
  // ==========================================================

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final initialDate = _selectedDateTime ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    TimeOfDay initialTime = TimeOfDay.now();

    if (_selectedDateTime != null) {
      initialTime = TimeOfDay(
        hour: _selectedDateTime!.hour,
        minute: _selectedDateTime!.minute,
      );
    }

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialTime.hour,
        initialTime.minute,
      );

      _errorMessage = null;
    });
  }

  // ==========================================================
  // SELECT TIME
  // ==========================================================

  Future<void> _selectTime() async {
    if (_selectedDateTime == null) {
      setState(() {
        _errorMessage = 'Please select a due date first.';
      });

      return;
    }

    final initialTime = TimeOfDay(
      hour: _selectedDateTime!.hour,
      minute: _selectedDateTime!.minute,
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime!.year,
        _selectedDateTime!.month,
        _selectedDateTime!.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      _errorMessage = null;
    });
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate() {
    if (_selectedDateTime == null) {
      return 'No date selected';
    }

    final day = _selectedDateTime!.day.toString().padLeft(2, '0');

    final month = _selectedDateTime!.month.toString().padLeft(2, '0');

    return '$day/$month/${_selectedDateTime!.year}';
  }

  // ==========================================================
  // FORMAT TIME
  // ==========================================================

  String _formatTime() {
    if (_selectedDateTime == null) {
      return 'No time selected';
    }

    final hour = _selectedDateTime!.hour.toString().padLeft(2, '0');

    final minute = _selectedDateTime!.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  // ==========================================================
  // SUBMIT
  // ==========================================================

  void _submit() {
    final title = _titleController.text.trim();

    final subject = _subjectController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a task name.';
      });

      return;
    }

    if (title.length < 2) {
      setState(() {
        _errorMessage = 'Task name must be at least 2 characters.';
      });

      return;
    }

    if (_selectedReminder != 'None' && _selectedDateTime == null) {
      setState(() {
        _errorMessage =
            'Please select a due date and time '
            'before choosing a reminder.';
      });

      return;
    }

    if (_selectedDateTime != null &&
        _selectedDateTime!.isBefore(DateTime.now()) &&
        _selectedReminder != 'None') {
      setState(() {
        _errorMessage =
            'The due date and time must be in the '
            'future when using a reminder.';
      });

      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop({
      'title': title,
      'subject': subject.isEmpty ? 'General' : subject,
      'dueDate': _selectedDateTime,
      'reminder': _selectedReminder,
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTitle != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'Add Task'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // ERROR MESSAGE
            // ==================================================
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ==================================================
            // TASK NAME
            // ==================================================
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Task name',
                hintText: 'e.g. Complete assignment',
                prefixIcon: Icon(Icons.task_alt),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // SUBJECT
            // ==================================================
            TextField(
              controller: _subjectController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g. Programming',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // DUE DATE
            // ==================================================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _selectedDateTime == null ? 'Select due date' : _formatDate(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // DUE TIME
            // ==================================================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _selectTime,
                icon: const Icon(Icons.access_time),
                label: Text(
                  _selectedDateTime == null ? 'Select due time' : _formatTime(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // REMINDER
            // ==================================================
            DropdownButtonFormField<String>(
              initialValue: _selectedReminder,
              decoration: const InputDecoration(
                labelText: 'Reminder',
                prefixIcon: Icon(Icons.notifications_none),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'None', child: Text('No reminder')),
                DropdownMenuItem(
                  value: '15 minutes before',
                  child: Text('15 minutes before'),
                ),
                DropdownMenuItem(
                  value: '30 minutes before',
                  child: Text('30 minutes before'),
                ),
                DropdownMenuItem(
                  value: '1 hour before',
                  child: Text('1 hour before'),
                ),
                DropdownMenuItem(
                  value: '1 day before',
                  child: Text('1 day before'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedReminder = value;
                  _errorMessage = null;
                });
              },
            ),
          ],
        ),
      ),

      // ========================================================
      // ACTIONS
      // ========================================================
      actions: [
        TextButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();

            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
