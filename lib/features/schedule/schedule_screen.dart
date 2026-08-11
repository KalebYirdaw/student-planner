import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<Map<String, String>> _scheduleItems = [
    {
      'day': 'Monday',
      'time': '08:00',
      'subject': 'Programming',
      'location': 'Room 201',
    },
    {
      'day': 'Monday',
      'time': '10:00',
      'subject': 'Database Systems',
      'location': 'Room 105',
    },
    {
      'day': 'Tuesday',
      'time': '09:00',
      'subject': 'Software Engineering',
      'location': 'Room 302',
    },
  ];

  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _times = const [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),

      body: _scheduleItems.isEmpty
          ? const Center(
              child: Text(
                'No schedule items yet.\nTap + to add a class.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _scheduleItems.length,
              itemBuilder: (context, index) {
                final item = _scheduleItems[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(item['time']!.substring(0, 2)),
                    ),

                    title: Text(
                      item['subject']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(
                      '${item['day']} • ${item['time']}\n'
                      '${item['location']}',
                    ),

                    isThreeLine: true,

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            _showScheduleDialog(editIndex: index);
                          },
                        ),

                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            _deleteSchedule(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showScheduleDialog();
        },
        tooltip: 'Add schedule',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteSchedule(int index) {
    final item = _scheduleItems[index];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Schedule'),

          content: Text(
            'Are you sure you want to delete '
            '"${item['subject']}"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                setState(() {
                  _scheduleItems.removeAt(index);
                });

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleDialog({int? editIndex}) {
    final bool isEditing = editIndex != null;

    final existingItem = isEditing ? _scheduleItems[editIndex] : null;

    String subject = existingItem?['subject'] ?? '';

    String location = existingItem?['location'] ?? '';

    String selectedDay = existingItem?['day'] ?? 'Monday';

    String selectedTime = existingItem?['time'] ?? '08:00';

    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Schedule' : 'Add Schedule'),

              content: Form(
                key: formKey,

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: subject,

                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          prefixIcon: Icon(Icons.school_outlined),
                          border: OutlineInputBorder(),
                        ),

                        onChanged: (value) {
                          subject = value;
                        },

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a subject';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        initialValue: location,

                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),

                        onChanged: (value) {
                          location = value;
                        },

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a location';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: selectedDay,

                        decoration: const InputDecoration(
                          labelText: 'Day',
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                          border: OutlineInputBorder(),
                        ),

                        items: _days.map((day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedDay = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: selectedTime,

                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.access_time_outlined),
                          border: OutlineInputBorder(),
                        ),

                        items: _times.map((time) {
                          return DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedTime = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    setState(() {
                      final updatedSchedule = {
                        'day': selectedDay,
                        'time': selectedTime,
                        'subject': subject.trim(),
                        'location': location.trim(),
                      };

                      if (isEditing) {
                        _scheduleItems[editIndex] = updatedSchedule;
                      } else {
                        _scheduleItems.add(updatedSchedule);
                      }
                    });

                    Navigator.of(dialogContext).pop();
                  },

                  child: Text(isEditing ? 'Save Changes' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
