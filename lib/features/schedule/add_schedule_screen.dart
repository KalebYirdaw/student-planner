import 'package:flutter/material.dart';

import 'schedule_model.dart';

class AddScheduleScreen extends StatefulWidget {
  final ScheduleModel? existingSchedule;

  const AddScheduleScreen({super.key, this.existingSchedule});

  bool get isEditing => existingSchedule != null;

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _eventNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingSchedule;

    _eventNameController = TextEditingController(text: existing?.subject ?? '');

    _locationController = TextEditingController(text: existing?.location ?? '');

    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );

    // The existing schedule currently stores the day/time as
    // strings, so we don't invent a date when editing.
    //
    // The date will be selected when creating a new event.
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  // ============================================================
  // SELECT START TIME
  // ============================================================

  Future<void> _selectStartTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    setState(() {
      _startTime = selectedTime;
    });
  }

  // ============================================================
  // SELECT END TIME
  // ============================================================

  Future<void> _selectEndTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    setState(() {
      _endTime = selectedTime;
    });
  }

  // ============================================================
  // SAVE EVENT
  // ============================================================

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null && !widget.isEditing) {
      _showError('Please select a date.');
      return;
    }

    if (_startTime == null) {
      _showError('Please select a start time.');
      return;
    }

    if (_endTime == null) {
      _showError('Please select an end time.');
      return;
    }

    if (_startTime!.hour > _endTime!.hour ||
        (_startTime!.hour == _endTime!.hour &&
            _startTime!.minute >= _endTime!.minute)) {
      _showError('End time must be after start time.');
      return;
    }

    final existing = widget.existingSchedule;

    final schedule = ScheduleModel(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      day: _selectedDate == null
          ? existing?.day ?? 'Monday'
          : _dayName(_selectedDate!),
      time: _formatTime(_startTime!),
      subject: _eventNameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(schedule);
  }

  // ============================================================
  // DAY NAME
  // ============================================================

  String _dayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  // ============================================================
  // SHOW ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Schedule Event' : 'Add Schedule Event',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.isEditing ? 'Edit Event' : 'Event Details',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // EVENT NAME
            // ==================================================
            TextFormField(
              controller: _eventNameController,
              decoration: const InputDecoration(
                labelText: 'Event name',
                hintText: 'e.g. Programming',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an event name.';
                }

                if (value.trim().length < 2) {
                  return 'Event name must be at least 2 characters.';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // ==================================================
            // DATE
            // ==================================================
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date'),
              subtitle: Text(
                _selectedDate == null
                    ? 'Select a date'
                    : _formatDate(_selectedDate!),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),

            const Divider(),

            // ==================================================
            // START TIME
            // ==================================================
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_outlined),
              title: const Text('Start time'),
              subtitle: Text(
                _startTime == null
                    ? 'Select start time'
                    : _formatTime(_startTime!),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectStartTime,
            ),

            const Divider(),

            // ==================================================
            // END TIME
            // ==================================================
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_filled_outlined),
              title: const Text('End time'),
              subtitle: Text(
                _endTime == null ? 'Select end time' : _formatTime(_endTime!),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectEndTime,
            ),

            const Divider(),

            const SizedBox(height: 16),

            // ==================================================
            // LOCATION
            // ==================================================
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g. Room 201',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Add additional information...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 28),

            // ==================================================
            // SAVE BUTTON
            // ==================================================
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saveEvent,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.isEditing ? 'Save Changes' : 'Save Event',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
