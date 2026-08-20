import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'assignment_model.dart';

class AssignmentStorageService {
  static const String _fileName = 'assignment_items.json';

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File('${directory.path}/$_fileName');
  }

  Future<List<Assignment>> loadAssignments() async {
    try {
      final file = await _getFile();

      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();

      if (contents.trim().isEmpty) {
        return [];
      }

      final List<dynamic> decodedData = jsonDecode(contents);

      return decodedData
          .map((item) => Assignment.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveAssignments(List<Assignment> assignments) async {
    final file = await _getFile();

    final List<Map<String, dynamic>> data = assignments
        .map((assignment) => assignment.toJson())
        .toList();

    await file.writeAsString(jsonEncode(data));
  }
}
