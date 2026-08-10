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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),

      body: _scheduleItems.isEmpty
          ? const Center(
              child: Text(
                'No schedule items yet.',
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

                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _scheduleItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddScheduleDialog() {
    String subject = '';
    String location = '';
    String selectedDay = 'Monday';
    String selectedTime = '08:00';

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Schedule'),

              content: Form(
                key: formKey,

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          prefixIcon: Icon(Icons.school_outlined),
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
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on_outlined),
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
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: 'Monday',
                            child: Text('Monday'),
                          ),
                          DropdownMenuItem(
                            value: 'Tuesday',
                            child: Text('Tuesday'),
                          ),
                          DropdownMenuItem(
                            value: 'Wednesday',
                            child: Text('Wednesday'),
                          ),
                          DropdownMenuItem(
                            value: 'Thursday',
                            child: Text('Thursday'),
                          ),
                          DropdownMenuItem(
                            value: 'Friday',
                            child: Text('Friday'),
                          ),
                          DropdownMenuItem(
                            value: 'Saturday',
                            child: Text('Saturday'),
                          ),
                          DropdownMenuItem(
                            value: 'Sunday',
                            child: Text('Sunday'),
                          ),
                        ],

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
                        ),

                        items: const [
                          DropdownMenuItem(
                            value: '08:00',
                            child: Text('08:00'),
                          ),
                          DropdownMenuItem(
                            value: '09:00',
                            child: Text('09:00'),
                          ),
                          DropdownMenuItem(
                            value: '10:00',
                            child: Text('10:00'),
                          ),
                          DropdownMenuItem(
                            value: '11:00',
                            child: Text('11:00'),
                          ),
                          DropdownMenuItem(
                            value: '12:00',
                            child: Text('12:00'),
                          ),
                          DropdownMenuItem(
                            value: '13:00',
                            child: Text('13:00'),
                          ),
                          DropdownMenuItem(
                            value: '14:00',
                            child: Text('14:00'),
                          ),
                          DropdownMenuItem(
                            value: '15:00',
                            child: Text('15:00'),
                          ),
                          DropdownMenuItem(
                            value: '16:00',
                            child: Text('16:00'),
                          ),
                          DropdownMenuItem(
                            value: '17:00',
                            child: Text('17:00'),
                          ),
                        ],

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
                      _scheduleItems.add({
                        'day': selectedDay,
                        'time': selectedTime,
                        'subject': subject.trim(),
                        'location': location.trim(),
                      });
                    });

                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
