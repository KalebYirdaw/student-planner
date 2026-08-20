import 'package:flutter/material.dart';

import 'assignment_model.dart';

class AddAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;

  const AddAssignmentScreen({super.key, this.assignment});

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDueDate;

  String _selectedPriority = 'Medium';

  int _progress = 0;

  bool get _isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();

    final assignment = widget.assignment;

    if (assignment != null) {
      _titleController.text = assignment.title;
      _subjectController.text = assignment.subject;
      _descriptionController.text = assignment.description;

      _selectedDueDate = assignment.dueDate;
      _selectedPriority = assignment.priority;
      _progress = assignment.progress;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  void _saveAssignment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date.')),
      );

      return;
    }

    final Assignment assignment = Assignment(
      id:
          widget.assignment?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDueDate!,
      priority: _selectedPriority,
      progress: _progress,
      isCompleted: _progress == 100,
    );

    Navigator.pop(context, assignment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Assignment' : 'Add Assignment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  hintText: 'e.g. Database Project',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an assignment title.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g. Database Systems',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter assignment details...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Due Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectDueDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _selectedDueDate == null
                        ? 'Select Due Date'
                        : '${_selectedDueDate!.day}/'
                              '${_selectedDueDate!.month}/'
                              '${_selectedDueDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Progress: $_progress%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Slider(
                value: _progress.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '$_progress%',
                onChanged: (value) {
                  setState(() {
                    _progress = value.round();
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveAssignment,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditing ? 'Save Changes' : 'Save Assignment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
