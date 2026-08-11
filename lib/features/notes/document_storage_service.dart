import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'document_model.dart';

class DocumentStorageService {
  static const String _documentsKey = 'saved_documents';

  // ============================================================
  // SAVE DOCUMENTS
  // ============================================================

  Future<void> saveDocuments(List<DocumentModel> documents) async {
    final preferences = await SharedPreferences.getInstance();

    final documentsJson = documents.map((document) {
      return {
        'name': document.name,
        'subject': document.subject,
        'path': document.path,
        'extension': document.extension,
        'size': document.size,
      };
    }).toList();

    await preferences.setString(_documentsKey, jsonEncode(documentsJson));
  }

  // ============================================================
  // LOAD DOCUMENTS
  // ============================================================

  Future<List<DocumentModel>> loadDocuments() async {
    final preferences = await SharedPreferences.getInstance();

    final savedDocuments = preferences.getString(_documentsKey);

    if (savedDocuments == null || savedDocuments.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> documentsJson = jsonDecode(savedDocuments);

      return documentsJson.map((document) {
        final data = Map<String, dynamic>.from(document);

        return DocumentModel(
          name: data['name'] as String? ?? '',
          subject: data['subject'] as String? ?? 'General',
          path: data['path'] as String? ?? '',
          extension: data['extension'] as String? ?? '',
          size: data['size'] as int? ?? 0,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // CLEAR DOCUMENTS
  // ============================================================

  Future<void> clearDocuments() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_documentsKey);
  }
}
