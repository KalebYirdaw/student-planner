import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      'priority': 'High',
      'completed': false,
    },
    {
      'title': 'Database Test',
      'subject': 'Database Systems',
      'due': 'Next Monday',
      'priority': 'Medium',
      'completed': false,
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
  // ADD TASK
  // ============================================================

  Future<void> _addTask() async {
    if (!mounted) {
      return;
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AddTaskDialog(),
    );

    if (!mounted || result == null) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted) {
      return;
    }

    final newTask = <String, dynamic>{
      'title': result['title'] ?? '',
      'subject': result['subject'] ?? 'General',
      'due': 'No date',
      'priority': 'Medium',
      'completed': false,
    };

    setState(() {
      _tasks.add(newTask);
    });

    await _saveTasks();

    if (!mounted) {
      return;
    }

    _showMessage('Task added successfully.');
  }

  // ============================================================
  // TOGGLE TASK
  // ============================================================

  Future<void> _toggleTask(int index) async {
    if (index < 0 || index >= _tasks.length) {
      return;
    }

    setState(() {
      final currentValue = _tasks[index]['completed'];

      _tasks[index]['completed'] = currentValue == true ? false : true;
    });

    await _saveTasks();
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
                'No tasks yet.\nTap + to add your first task.',
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

                  final completed = task['completed'] == true;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),

                    child: ListTile(
                      // ==========================================
                      // CHECKBOX
                      // ==========================================
                      leading: Checkbox(
                        value: completed,
                        onChanged: (_) {
                          _toggleTask(index);
                        },
                      ),

                      // ==========================================
                      // TASK TITLE
                      // ==========================================
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),

                      // ==========================================
                      // TASK DETAILS
                      // ==========================================
                      subtitle: Text('$subject • Due $due'),

                      // ==========================================
                      // PRIORITY
                      // ==========================================
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Task options',

                        icon: const Icon(Icons.more_vert),

                        onSelected: (value) {
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
// ADD TASK DIALOG
// ============================================================

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();

  String? _errorMessage;

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

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(
      context,
    ).pop({'title': title, 'subject': subject.isEmpty ? 'General' : subject});
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),

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
              autofocus: true,
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

              onSubmitted: (_) {
                _submit();
              },

              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g. Programming',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
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

        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
