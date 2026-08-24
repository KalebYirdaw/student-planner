import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../assignments/assignment_model.dart';
import '../assignments/assignment_storage_service.dart';
import '../assignments/assignments_screen.dart';
import '../notes/document_model.dart';
import '../notes/notes_screen.dart';
import '../schedule/schedule_model.dart';
import '../schedule/schedule_screen.dart';
import '../tasks/tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _tasksStorageKey = 'student_planner_tasks';
  static const String _notesStorageKey = 'student_planner_notes';
  static const String _documentsStorageKey = 'student_planner_documents';

  static const String _scheduleFileName = 'schedule_items.json';

  // ============================================================
  // DATA
  // ============================================================

  List<ScheduleModel> _schedules = [];
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, String>> _notes = [];
  List<DocumentModel> _documents = [];
  List<Assignment> _assignments = [];

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = true;

  Timer? _refreshTimer;

  // ============================================================
  // MOTIVATIONAL MESSAGES
  // ============================================================

  static const List<String> _motivationalMessages = [
    'Small progress is still progress. Keep going! 💪',
    'You do not have to be perfect. Just keep moving forward. 🌱',
    'One task at a time. You have got this! 🎯',
    'Your future self will thank you for what you do today. 🚀',
    'Stay consistent. Your hard work will pay off. 🔥',
    'Believe in yourself and keep pushing forward. ⭐',
    'Focus on progress, not perfection. 💙',
    'Every study session brings you one step closer to your goals. 📚',
    'You are capable of more than you think. Keep going! 💯',
    'Make today count. Your goals are worth it. 🏆',
  ];

  String get _motivationalMessage {
    final now = DateTime.now();

    final startOfYear = DateTime(now.year, 1, 1);

    final dayIndex = now.difference(startOfYear).inDays;

    return _motivationalMessages[dayIndex % _motivationalMessages.length];
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadHomeData();

    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _loadHomeData(showLoading: false);
      }
    });
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadHomeData(showLoading: false);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _refreshTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // ============================================================
  // LOAD ALL HOME DATA
  // ============================================================

  Future<void> _loadHomeData({bool showLoading = true}) async {
    try {
      if (showLoading && mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final schedule = await _loadSchedules();
      final tasks = await _loadTasks();
      final notes = await _loadNotes();
      final documents = await _loadDocuments();

      final assignmentStorage = AssignmentStorageService();

      final assignments = await assignmentStorage.loadAssignments();

      if (!mounted) {
        return;
      }

      setState(() {
        _schedules = schedule;
        _tasks = tasks;
        _notes = notes;
        _documents = documents;
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // LOAD SCHEDULE
  // ============================================================

  Future<List<ScheduleModel>> _loadSchedules() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final file = File('${directory.path}/$_scheduleFileName');

      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();

      if (contents.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(contents);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => ScheduleModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // LOAD TASKS
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadTasks() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedTasks = preferences.getString(_tasksStorageKey);

      if (savedTasks == null || savedTasks.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(savedTasks);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (task) => Map<String, dynamic>.from(
              task.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // LOAD NOTES
  // ============================================================

  Future<List<Map<String, String>>> _loadNotes() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedNotes = preferences.getString(_notesStorageKey);

      if (savedNotes == null || savedNotes.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(savedNotes);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (note) => <String, String>{
              'title': note['title']?.toString() ?? '',
              'subject': note['subject']?.toString() ?? 'General',
              'content': note['content']?.toString() ?? '',
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // LOAD DOCUMENTS
  // ============================================================

  Future<List<DocumentModel>> _loadDocuments() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final savedDocuments = preferences.getString(_documentsStorageKey);

      if (savedDocuments == null || savedDocuments.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(savedDocuments);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (document) =>
                DocumentModel.fromJson(Map<String, dynamic>.from(document)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // TODAY'S SCHEDULE
  // ============================================================

  List<ScheduleModel> get _todaySchedules {
    final today = _todayName();

    final schedules = _schedules
        .where(
          (schedule) =>
              schedule.day.trim().toLowerCase() == today.toLowerCase(),
        )
        .toList();

    schedules.sort(_compareSchedules);

    return schedules;
  }

  // ============================================================
  // TODAY NAME
  // ============================================================

  String _todayName() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[DateTime.now().weekday - 1];
  }

  // ============================================================
  // SORT SCHEDULE
  // ============================================================

  int _compareSchedules(ScheduleModel first, ScheduleModel second) {
    return _timeToMinutes(first.time).compareTo(_timeToMinutes(second.time));
  }

  // ============================================================
  // TIME TO MINUTES
  // ============================================================

  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');

      if (parts.length != 2) {
        return 0;
      }

      final hour = int.tryParse(parts[0]) ?? 0;

      final minutePart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');

      final minute = int.tryParse(minutePart) ?? 0;

      final lower = time.toLowerCase();

      final isPm = lower.contains('pm');
      final isAm = lower.contains('am');

      var adjustedHour = hour;

      if (isPm && hour != 12) {
        adjustedHour += 12;
      }

      if (isAm && hour == 12) {
        adjustedHour = 0;
      }

      return adjustedHour * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  // ============================================================
  // COMPLETED TASKS
  // ============================================================

  int get _completedTasks {
    return _tasks.where((task) => task['completed'] == true).length;
  }

  // ============================================================
  // COMPLETED ASSIGNMENTS
  // ============================================================

  int get _completedAssignments {
    return _assignments.where((assignment) => assignment.isCompleted).length;
  }

  // ============================================================
  // TOTAL ACADEMIC ITEMS
  // ============================================================

  int get _totalAcademicItems {
    return _tasks.length + _assignments.length;
  }

  // ============================================================
  // COMPLETED ACADEMIC ITEMS
  // ============================================================

  int get _completedAcademicItems {
    return _completedTasks + _completedAssignments;
  }

  // ============================================================
  // ACADEMIC PROGRESS
  // ============================================================

  double get _academicProgress {
    if (_totalAcademicItems == 0) {
      return 0;
    }

    return _completedAcademicItems / _totalAcademicItems;
  }

  // ============================================================
  // PROGRESS PERCENTAGE
  // ============================================================

  int get _progressPercentage {
    return (_academicProgress * 100).round();
  }

  // ============================================================
  // UPCOMING TASKS
  // ============================================================

  List<Map<String, dynamic>> get _upcomingTasks {
    return _tasks.where((task) => task['completed'] != true).take(3).toList();
  }

  // ============================================================
  // UPCOMING ASSIGNMENTS
  // ============================================================

  List<Assignment> get _upcomingAssignments {
    final assignments = _assignments
        .where((assignment) => !assignment.isCompleted)
        .toList();

    assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return assignments.take(3).toList();
  }

  // ============================================================
  // NEEDS ATTENTION
  // ============================================================

  List<Assignment> get _attentionAssignments {
    final assignments = _assignments
        .where(
          (assignment) =>
              !assignment.isCompleted && assignment.daysUntilDue <= 3,
        )
        .toList();

    assignments.sort((a, b) {
      return a.daysUntilDue.compareTo(b.daysUntilDue);
    });

    return assignments;
  }

  // ============================================================
  // HIGH PRIORITY TASKS
  // ============================================================

  List<Map<String, dynamic>> get _attentionTasks {
    return _tasks.where((task) {
      final completed = task['completed'] == true;

      final priority = task['priority']?.toString().toLowerCase();

      return !completed && priority == 'high';
    }).toList();
  }

  // ============================================================
  // DOES SOMETHING NEED ATTENTION?
  // ============================================================

  bool get _hasAttentionItems {
    return _attentionAssignments.isNotEmpty || _attentionTasks.isNotEmpty;
  }

  // ============================================================
  // NAVIGATE TO PAGE
  // ============================================================

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    if (!mounted) {
      return;
    }

    await _loadHomeData(showLoading: false);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Planner'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              _loadHomeData(showLoading: false);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadHomeData(showLoading: false),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  _buildGreeting(),

                  const SizedBox(height: 24),

                  _buildOverview(),

                  const SizedBox(height: 20),

                  _buildAcademicProgress(),

                  if (_hasAttentionItems) ...[
                    const SizedBox(height: 28),
                    _buildNeedsAttention(),
                  ],

                  const SizedBox(height: 28),

                  _buildTodaySchedule(),

                  const SizedBox(height: 28),

                  _buildAssignments(),

                  const SizedBox(height: 28),

                  _buildTasks(),

                  const SizedBox(height: 28),

                  _buildNotes(),

                  const SizedBox(height: 28),

                  _buildDocuments(),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;

    String greeting;

    if (hour < 12) {
      greeting = 'Good morning 👋';
    } else if (hour < 18) {
      greeting = 'Good afternoon 👋';
    } else {
      greeting = 'Good evening 👋';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          'Here is your plan for today.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),

        const SizedBox(height: 10),

        Text(
          _motivationalMessage,
          style: TextStyle(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Overview",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: 'Classes',
                value: '${_todaySchedules.length}',
                icon: Icons.school_outlined,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _OverviewCard(
                title: 'Tasks',
                value: '${_tasks.length}',
                icon: Icons.task_alt_outlined,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _OverviewCard(
                title: 'Assignments',
                value: '${_assignments.length}',
                icon: Icons.assignment_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                title: 'Notes',
                value: '${_notes.length}',
                icon: Icons.note_outlined,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _OverviewCard(
                title: 'Documents',
                value: '${_documents.length}',
                icon: Icons.description_outlined,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _OverviewCard(
                title: 'Completed',
                value: '$_completedAcademicItems',
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ACADEMIC PROGRESS
  // ============================================================

  Widget _buildAcademicProgress() {
    final total = _totalAcademicItems;

    final completed = _completedAcademicItems;

    final progress = _academicProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Your Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Text(
                  '$_progressPercentage%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: progress, minHeight: 9),
            ),

            const SizedBox(height: 10),

            Text(
              total == 0
                  ? 'Add tasks or assignments to start tracking your progress.'
                  : '$completed of $total tasks and assignments completed.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NEEDS ATTENTION
  // ============================================================

  Widget _buildNeedsAttention() {
    final assignments = _attentionAssignments;

    final tasks = _attentionTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Needs Attention',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...assignments.take(3).map((assignment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AttentionAssignmentCard(assignment: assignment),
          );
        }),

        ...tasks.take(3).map((task) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AttentionTaskCard(task: task),
          );
        }),
      ],
    );
  }

  // ============================================================
  // TODAY'S SCHEDULE
  // ============================================================

  Widget _buildTodaySchedule() {
    final schedules = _todaySchedules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Today's Schedule",
          onPressed: () {
            _openPage(const ScheduleScreen());
          },
        ),

        const SizedBox(height: 12),

        if (schedules.isEmpty)
          _EmptyCard(
            icon: Icons.event_available_outlined,
            message: 'No classes or events scheduled for today.',
            buttonText: 'Open Schedule',
            onPressed: () {
              _openPage(const ScheduleScreen());
            },
          )
        else
          ...schedules.take(5).map((schedule) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScheduleCard(schedule: schedule),
            );
          }),
      ],
    );
  }

  // ============================================================
  // ASSIGNMENTS
  // ============================================================

  Widget _buildAssignments() {
    final assignments = _upcomingAssignments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Assignments',
          onPressed: () {
            _openPage(const AssignmentsScreen());
          },
        ),

        const SizedBox(height: 12),

        if (assignments.isEmpty)
          _EmptyCard(
            icon: Icons.assignment_outlined,
            message: 'You have no outstanding assignments.',
            buttonText: 'Open Assignments',
            onPressed: () {
              _openPage(const AssignmentsScreen());
            },
          )
        else
          ...assignments.map((assignment) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AssignmentCard(assignment: assignment),
            );
          }),
      ],
    );
  }

  // ============================================================
  // TASKS
  // ============================================================

  Widget _buildTasks() {
    final tasks = _upcomingTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Tasks',
          onPressed: () {
            _openPage(const TasksScreen());
          },
        ),

        const SizedBox(height: 12),

        if (tasks.isEmpty)
          _EmptyCard(
            icon: Icons.task_alt_outlined,
            message: 'You have no outstanding tasks.',
            buttonText: 'Open Tasks',
            onPressed: () {
              _openPage(const TasksScreen());
            },
          )
        else
          ...tasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskCard(
                title: task['title']?.toString() ?? 'Untitled Task',
                subject: task['subject']?.toString() ?? 'General',
                due: task['due']?.toString() ?? 'No date',
                priority: task['priority']?.toString() ?? 'Medium',
              ),
            );
          }),
      ],
    );
  }

  // ============================================================
  // NOTES
  // ============================================================

  Widget _buildNotes() {
    final notes = _notes.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Notes',
          onPressed: () {
            _openPage(const NotesScreen());
          },
        ),

        const SizedBox(height: 12),

        if (notes.isEmpty)
          _EmptyCard(
            icon: Icons.note_outlined,
            message: 'You have not created any notes yet.',
            buttonText: 'Open Notes',
            onPressed: () {
              _openPage(const NotesScreen());
            },
          )
        else
          ...notes.map((note) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NoteCard(
                title: note['title'] ?? 'Untitled Note',
                subject: note['subject'] ?? 'General',
                content: note['content'] ?? '',
              ),
            );
          }),
      ],
    );
  }

  // ============================================================
  // DOCUMENTS
  // ============================================================

  Widget _buildDocuments() {
    final documents = _documents.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Documents',
          onPressed: () {
            _openPage(const NotesScreen());
          },
        ),

        const SizedBox(height: 12),

        if (documents.isEmpty)
          _EmptyCard(
            icon: Icons.folder_open_outlined,
            message: 'No documents uploaded yet.',
            buttonText: 'Open Notes & Documents',
            onPressed: () {
              _openPage(const NotesScreen());
            },
          )
        else
          ...documents.map((document) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DocumentCard(document: document),
            );
          }),
      ],
    );
  }
}

// ============================================================
// OVERVIEW CARD
// ============================================================

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 26),

            const SizedBox(height: 7),

            Text(
              value,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _SectionHeader({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        TextButton(onPressed: onPressed, child: const Text('View all')),
      ],
    );
  }
}

// ============================================================
// ATTENTION ASSIGNMENT CARD
// ============================================================

class _AttentionAssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AttentionAssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final overdue = assignment.isOverdue;

    final dueToday = assignment.daysUntilDue == 0;

    String message;

    if (overdue) {
      message = assignment.dueDateLabel;
    } else if (dueToday) {
      message = 'Due today';
    } else {
      message = 'Due in ${assignment.daysUntilDue} days';
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            overdue ? Icons.warning_amber_outlined : Icons.schedule_outlined,
          ),
        ),

        title: Text(
          assignment.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          '${assignment.subject} • $message',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        trailing: Text(
          overdue ? 'OVERDUE' : 'SOON',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ============================================================
// ATTENTION TASK CARD
// ============================================================

class _AttentionTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _AttentionTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final title = task['title']?.toString() ?? 'Untitled Task';

    final subject = task['subject']?.toString() ?? 'General';

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.priority_high_outlined)),

        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text('$subject • High priority'),

        trailing: const Text(
          'IMPORTANT',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ============================================================
// SCHEDULE CARD
// ============================================================

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            schedule.time.length >= 2 ? schedule.time.substring(0, 2) : '--',
          ),
        ),

        title: Text(
          schedule.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text('${schedule.time} • ${schedule.location}'),

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ============================================================
// ASSIGNMENT CARD
// ============================================================

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            assignment.isOverdue
                ? Icons.warning_amber_outlined
                : Icons.assignment_outlined,
          ),
        ),

        title: Text(
          assignment.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          '${assignment.subject} • '
          '${assignment.dueDateLabel}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        trailing: Text(
          '${assignment.progress}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ============================================================
// TASK CARD
// ============================================================

class _TaskCard extends StatelessWidget {
  final String title;
  final String subject;
  final String due;
  final String priority;

  const _TaskCard({
    required this.title,
    required this.subject,
    required this.due,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.task_alt_outlined)),

        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text('$subject • Due $due'),

        trailing: _PriorityLabel(priority: priority),
      ),
    );
  }
}

// ============================================================
// NOTE CARD
// ============================================================

class _NoteCard extends StatelessWidget {
  final String title;
  final String subject;
  final String content;

  const _NoteCard({
    required this.title,
    required this.subject,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.note_outlined)),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(
          '$subject\n$content',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        isThreeLine: true,

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ============================================================
// DOCUMENT CARD
// ============================================================

class _DocumentCard extends StatelessWidget {
  final DocumentModel document;

  const _DocumentCard({required this.document});

  IconData _getIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;

      case 'doc':
      case 'docx':
        return Icons.description_outlined;

      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;

      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;

      case 'txt':
      case 'csv':
        return Icons.text_snippet_outlined;

      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(_getIcon(document.extension))),

        title: Text(
          document.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          '${document.subject} • '
          '${document.fileType} • '
          '${document.formattedSize}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

// ============================================================
// PRIORITY LABEL
// ============================================================

class _PriorityLabel extends StatelessWidget {
  final String priority;

  const _PriorityLabel({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Text(
      priority,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}

// ============================================================
// EMPTY CARD
// ============================================================

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 42),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 12),

            OutlinedButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}
