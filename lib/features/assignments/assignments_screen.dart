import 'package:flutter/material.dart';

import 'add_assignment_screen.dart';
import 'assignment_model.dart';
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

  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    _loadAssignments();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD ASSIGNMENTS
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // SAVE ASSIGNMENTS
  // ------------------------------------------------------------

  Future<void> _saveAssignments() async {
    await _storageService.saveAssignments(_assignments);
  }

  // ------------------------------------------------------------
  // ADD ASSIGNMENT
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // EDIT ASSIGNMENT
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // DELETE ASSIGNMENT
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // SEARCH AND FILTER
  // ------------------------------------------------------------

  List<Assignment> get _filteredAssignments {
    final String searchText = _searchController.text.trim().toLowerCase();

    return _assignments.where((assignment) {
      final bool matchesSearch =
          assignment.title.toLowerCase().contains(searchText) ||
          assignment.subject.toLowerCase().contains(searchText);

      if (!matchesSearch) {
        return false;
      }

      switch (_selectedFilter) {
        case 'Active':
          return !assignment.isCompleted;

        case 'Completed':
          return assignment.isCompleted;

        case 'Overdue':
          return assignment.isOverdue;

        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  // ------------------------------------------------------------
  // PRIORITY
  // ------------------------------------------------------------

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;

      case 'Medium':
        return Colors.orange;

      case 'Low':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  Widget _buildPriorityBadge(String priority) {
    final Color color = _priorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DUE DATE
  // ------------------------------------------------------------

  Widget _buildDueDateRow(Assignment assignment) {
    IconData icon;
    Color color;

    if (assignment.isCompleted) {
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else if (assignment.isOverdue) {
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    } else if (assignment.daysUntilDue <= 3) {
      icon = Icons.schedule;
      color = Colors.orange;
    } else {
      icon = Icons.calendar_today_outlined;
      color = Colors.grey.shade700;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          assignment.dueDateLabel,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // PROGRESS
  // ------------------------------------------------------------

  Widget _buildProgressSection(Assignment assignment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              '${assignment.progress}%',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: assignment.progress / 100,
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ASSIGNMENT CARD
  // ------------------------------------------------------------

  Widget _buildAssignmentCard(Assignment assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _editAssignment(assignment);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    assignment.isCompleted
                        ? Icons.check_circle
                        : assignment.isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.assignment_outlined,
                    size: 28,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          assignment.subject,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editAssignment(assignment);
                      } else if (value == 'delete') {
                        _deleteAssignment(assignment);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDueDateRow(assignment),
                  _buildPriorityBadge(assignment.priority),
                ],
              ),

              const SizedBox(height: 16),

              _buildProgressSection(assignment),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FILTER CHIP
  // ------------------------------------------------------------

  Widget _buildFilterChip(String filter) {
    final bool isSelected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY SEARCH STATE
  // ------------------------------------------------------------

  Widget _buildEmptySearchState() {
    String message;

    if (_searchController.text.trim().isNotEmpty) {
      message = 'No assignments match your search.';
    } else if (_selectedFilter == 'Completed') {
      message = 'No completed assignments.';
    } else if (_selectedFilter == 'Overdue') {
      message = 'No overdue assignments.';
    } else if (_selectedFilter == 'Active') {
      message = 'No active assignments.';
    } else {
      message = 'No assignments yet.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD BODY
  // ------------------------------------------------------------

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Assignment> filteredAssignments = _filteredAssignments;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search assignments...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();

                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        SizedBox(
          height: 50,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('All'),
              _buildFilterChip('Active'),
              _buildFilterChip('Completed'),
              _buildFilterChip('Overdue'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: filteredAssignments.isEmpty
              ? _buildEmptySearchState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filteredAssignments.length,
                  itemBuilder: (context, index) {
                    return _buildAssignmentCard(filteredAssignments[index]);
                  },
                ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // MAIN BUILD
  // ------------------------------------------------------------

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
}
