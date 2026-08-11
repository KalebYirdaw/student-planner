import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'add_schedule_screen.dart';
import 'schedule_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // ============================================================
  // LOCAL STORAGE
  // ============================================================

  static const String _fileName = 'schedule_items.json';

  // ============================================================
  // SCHEDULE DATA
  // ============================================================

  final List<ScheduleModel> _scheduleItems = [];

  // ============================================================
  // DAYS
  // ============================================================

  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // ============================================================
  // LOADING STATE
  // ============================================================

  bool _isLoading = true;

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadSchedule();
  }

  // ============================================================
  // GET STORAGE FILE
  // ============================================================

  Future<File> _getStorageFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File('${directory.path}/$_fileName');
  }

  // ============================================================
  // LOAD SCHEDULE
  // ============================================================

  Future<void> _loadSchedule() async {
    try {
      final file = await _getStorageFile();

      if (!await file.exists()) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final contents = await file.readAsString();

      if (contents.trim().isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        return;
      }

      final decoded = jsonDecode(contents);

      if (decoded is! List) {
        throw const FormatException('Invalid schedule storage format.');
      }

      final loadedSchedules = decoded
          .whereType<Map>()
          .map(
            (item) => ScheduleModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _scheduleItems
          ..clear()
          ..addAll(loadedSchedules);

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _scheduleItems.clear();
        _isLoading = false;
      });

      _showMessage('Could not load saved schedules.');
    }
  }

  // ============================================================
  // SAVE SCHEDULE
  // ============================================================

  Future<bool> _saveSchedule() async {
    try {
      final file = await _getStorageFile();

      final data = _scheduleItems.map((schedule) => schedule.toJson()).toList();

      final encoded = jsonEncode(data);

      await file.writeAsString(encoded, flush: true);

      return true;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // ADD SCHEDULE
  // ============================================================

  Future<void> _addSchedule() async {
    if (!mounted) {
      return;
    }

    final result = await Navigator.of(context).push<ScheduleModel>(
      MaterialPageRoute(builder: (_) => const AddScheduleScreen()),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _scheduleItems.add(result);
    });

    final saved = await _saveSchedule();

    if (!mounted) {
      return;
    }

    if (!saved) {
      setState(() {
        _scheduleItems.removeWhere((item) => item.id == result.id);
      });

      _showMessage('Schedule could not be saved.');

      return;
    }

    _showMessage('${result.subject} added successfully.');
  }

  // ============================================================
  // EDIT SCHEDULE
  // ============================================================

  Future<void> _editSchedule(int index) async {
    if (index < 0 || index >= _scheduleItems.length) {
      return;
    }

    final existingSchedule = _scheduleItems[index];

    final result = await Navigator.of(context).push<ScheduleModel>(
      MaterialPageRoute(
        builder: (_) => AddScheduleScreen(existingSchedule: existingSchedule),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final previousSchedule = _scheduleItems[index];

    setState(() {
      _scheduleItems[index] = result;
    });

    final saved = await _saveSchedule();

    if (!mounted) {
      return;
    }

    if (!saved) {
      setState(() {
        _scheduleItems[index] = previousSchedule;
      });

      _showMessage('Schedule changes could not be saved.');

      return;
    }

    _showMessage('${result.subject} updated successfully.');
  }

  // ============================================================
  // DELETE SCHEDULE
  // ============================================================

  Future<void> _deleteSchedule(int index) async {
    if (index < 0 || index >= _scheduleItems.length) {
      return;
    }

    final item = _scheduleItems[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Schedule'),
          content: Text(
            'Are you sure you want to delete '
            '"${item.subject}"?',
          ),
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

    setState(() {
      _scheduleItems.removeAt(index);
    });

    final saved = await _saveSchedule();

    if (!mounted) {
      return;
    }

    if (!saved) {
      setState(() {
        _scheduleItems.insert(index, item);
      });

      _showMessage('Schedule could not be deleted.');

      return;
    }

    _showMessage('Schedule deleted.');
  }

  // ============================================================
  // SHOW SCHEDULE DETAILS
  // ============================================================

  Future<void> _showScheduleDetails(ScheduleModel schedule) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            schedule.subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: 'Day', value: schedule.day),
                const SizedBox(height: 12),
                _DetailRow(label: 'Time', value: schedule.time),
                const SizedBox(height: 12),
                _DetailRow(label: 'Location', value: schedule.location),
                if (schedule.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Description', value: schedule.description),
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addSchedule,
        tooltip: 'Add schedule',
        child: const Icon(Icons.add),
      ),
    );
  }

  // ============================================================
  // BUILD BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_scheduleItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No schedule items yet.\n\n'
            'Tap + to add your first class or event.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final sortedItems = List<ScheduleModel>.from(_scheduleItems);

    sortedItems.sort(_compareSchedules);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedItems.length,
      itemBuilder: (context, index) {
        final item = sortedItems[index];

        final realIndex = _scheduleItems.indexWhere(
          (schedule) => schedule.id == item.id,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(child: Text(_displayHour(item.time))),
            title: Text(
              item.subject,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${item.day} • ${item.time}\n'
              '${item.location}',
            ),
            isThreeLine: true,
            onTap: () {
              _showScheduleDetails(item);
            },
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (realIndex < 0) {
                  return;
                }

                if (value == 'details') {
                  _showScheduleDetails(item);
                }

                if (value == 'edit') {
                  _editSchedule(realIndex);
                }

                if (value == 'delete') {
                  _deleteSchedule(realIndex);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'details', child: Text('View Details')),
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SORT SCHEDULES
  // ============================================================

  int _compareSchedules(ScheduleModel first, ScheduleModel second) {
    final firstDay = _days.indexOf(first.day);
    final secondDay = _days.indexOf(second.day);

    if (firstDay != secondDay) {
      return firstDay.compareTo(secondDay);
    }

    return _timeToMinutes(first.time).compareTo(_timeToMinutes(second.time));
  }

  // ============================================================
  // CONVERT TIME TO MINUTES
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

      final isPm = time.toLowerCase().contains('pm');
      final isAm = time.toLowerCase().contains('am');

      var adjustedHour = hour;

      if (isPm && hour != 12) {
        adjustedHour += 12;
      }

      if (isAm && hour == 12) {
        adjustedHour = 0;
      }

      return (adjustedHour * 60) + minute;
    } catch (_) {
      return 0;
    }
  }

  // ============================================================
  // DISPLAY HOUR
  // ============================================================

  String _displayHour(String time) {
    final trimmedTime = time.trim();

    if (trimmedTime.isEmpty) {
      return '--';
    }

    if (trimmedTime.length >= 2) {
      return trimmedTime.substring(0, 2);
    }

    return trimmedTime;
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value.trim().isEmpty ? 'Not provided' : value)),
      ],
    );
  }
}
