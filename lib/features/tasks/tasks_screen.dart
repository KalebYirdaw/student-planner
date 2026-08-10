import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> _tasks = [
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

  Future<void> _addTask() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return const _AddTaskDialog();
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _tasks.add({
        'title': result['title']!,
        'subject': result['subject']!,
        'due': 'No date',
        'priority': 'Medium',
        'completed': false,
      });
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['completed'] = !(_tasks[index]['completed'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _tasks
        .where((task) => task['completed'] == true)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),

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

                const Text(
                  'Your Tasks',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...List.generate(_tasks.length, (index) {
                  final task = _tasks[index];
                  final completed = task['completed'] as bool;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),

                    child: ListTile(
                      leading: Checkbox(
                        value: completed,
                        onChanged: (_) {
                          _toggleTask(index);
                        },
                      ),

                      title: Text(
                        task['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),

                      subtitle: Text(
                        '${task['subject']} • '
                        'Due ${task['due']}',
                      ),

                      trailing: Chip(label: Text(task['priority'] as String)),
                    ),
                  );
                }),
              ],
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Separate dialog widget.
///
/// Keeping the controllers inside the dialog means
/// Flutter controls their lifecycle correctly.
class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _subjectController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final subject = _subjectController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name.')),
      );

      return;
    }

    Navigator.of(
      context,
    ).pop({'title': title, 'subject': subject.isEmpty ? 'General' : subject});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              textInputAction: TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Task name',
                prefixIcon: Icon(Icons.task_alt),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _subjectController,
              textInputAction: TextInputAction.done,

              onSubmitted: (_) {
                _submit();
              },

              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),

        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
