import 'package:flutter/material.dart';
import 'app.dart';
import 'features/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();
  await NotificationService.instance.requestPermission();

  runApp(const StudentPlannerApp());
}
