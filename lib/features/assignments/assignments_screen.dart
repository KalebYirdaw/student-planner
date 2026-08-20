import 'package:flutter/material.dart';

import 'assignment_model.dart';
import 'add_assignment_screen.dart';
import 'assignment_storage_service.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final AssignmentStorageService _storageService = AssignmentStorageService();

  List<Assignment> _assignments = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final assignments = await _storageService.loadAssignments();

    if (!mounted) {
      return;
    }

    setState(() {
      _assignments = assignments;
      _isLoading = false;
    });
  }

  Future<void> _saveAssignments() async {
    await _storageService.saveAssignments(_assignments);
  }

  Future<void> _openAddAssignmentScreen() async {
    final Assignment? newAssignment = await Navigator.push<Assignment>(
      context,
      MaterialPageRoute(builder: (context) => const AddAssignmentScreen()),
    );

    if (newAssignment != null) {
      setState(() {
        _assignments.add(newAssignment);
      });

      await _saveAssignments();
    }
  }

  Future<void> _editAssignment(Assignment assignment) async {
    final Assignment? updatedAssignment = await Navigator.push<Assignment>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssignmentScreen(assignment: assignment),
      ),
    );

    if (updatedAssignment != null) {
      setState(() {
        final int index = _assignments.indexWhere(
          (item) => item.id == updatedAssignment.id,
        );

        if (index != -1) {
          _assignments[index] = updatedAssignment;
        }
      });

      await _saveAssignments();
    }
  }

  Future<void> _deleteAssignment(Assignment assignment) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: Text(
            'Are you sure you want to delete '
            '"${assignment.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _assignments.removeWhere((item) => item.id == assignment.id);
    });

    await _saveAssignments();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Assignment deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddAssignmentScreen,
        tooltip: 'Add Assignment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'No assignments yet.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Tap + to add your first assignment.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignments.length,
      itemBuilder: (context, index) {
        final Assignment assignment = _assignments[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            onTap: () {
              _editAssignment(assignment);
            },
            title: Text(
              assignment.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${assignment.subject}\n'
              'Due: ${assignment.dueDate.day}/'
              '${assignment.dueDate.month}/'
              '${assignment.dueDate.year}\n'
              'Priority: ${assignment.priority}\n'
              'Progress: ${assignment.progress}%',
            ),
            isThreeLine: true,
            leading: Icon(
              assignment.isCompleted
                  ? Icons.check_circle
                  : Icons.assignment_outlined,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Assignment',
              onPressed: () {
                _deleteAssignment(assignment);
              },
            ),
          ),
        );
      },
    );
  }
}
