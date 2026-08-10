import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Planner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning 👋',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Here is your plan for today.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

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
                    value: '3',
                    icon: Icons.school_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    title: 'Tasks',
                    value: '5',
                    icon: Icons.task_alt_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    title: 'Exams',
                    value: '1',
                    icon: Icons.assignment_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _ScheduleCard(
              time: '08:00',
              title: 'Programming',
              location: 'Room 201',
            ),

            const SizedBox(height: 10),

            _ScheduleCard(
              time: '10:00',
              title: 'Database Systems',
              location: 'Room 105',
            ),

            const SizedBox(height: 10),

            _ScheduleCard(
              time: '12:00',
              title: 'Study Session',
              location: 'Library',
            ),

            const SizedBox(height: 28),

            const Text(
              'Upcoming Deadlines',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _DeadlineCard(title: 'Programming Assignment', date: 'Due Friday'),

            const SizedBox(height: 10),

            _DeadlineCard(title: 'Database Test', date: 'Next Monday'),
          ],
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String time;
  final String title;
  final String location;

  const _ScheduleCard({
    required this.time,
    required this.title,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String title;
  final String date;

  const _DeadlineCard({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications_none),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
      ),
    );
  }
}
