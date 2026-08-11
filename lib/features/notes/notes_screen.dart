import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'document_model.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // ============================================================
  // NOTES DATA
  // ============================================================

  final List<Map<String, String>> _notes = [
    {
      'title': 'Programming Basics',
      'subject': 'Programming',
      'content':
          'Variables, data types, loops, conditions and object-oriented programming.',
    },
    {
      'title': 'Database Revision',
      'subject': 'Database Systems',
      'content':
          'SQL queries, tables, primary keys, foreign keys and relationships.',
    },
  ];

  // ============================================================
  // DOCUMENT DATA
  // ============================================================

  final List<DocumentModel> _documents = [];

  String _searchQuery = '';

  bool _isPickingDocument = false;

  // ============================================================
  // FILTER NOTES
  // ============================================================

  List<Map<String, String>> get _filteredNotes {
    if (_searchQuery.trim().isEmpty) {
      return List<Map<String, String>>.from(_notes);
    }

    final query = _searchQuery.trim().toLowerCase();

    return _notes.where((note) {
      final title = note['title']?.toLowerCase() ?? '';
      final subject = note['subject']?.toLowerCase() ?? '';
      final content = note['content']?.toLowerCase() ?? '';

      return title.contains(query) ||
          subject.contains(query) ||
          content.contains(query);
    }).toList();
  }

  // ============================================================
  // FILTER DOCUMENTS
  // ============================================================

  List<DocumentModel> get _filteredDocuments {
    if (_searchQuery.trim().isEmpty) {
      return List<DocumentModel>.from(_documents);
    }

    final query = _searchQuery.trim().toLowerCase();

    return _documents.where((document) {
      return document.name.toLowerCase().contains(query) ||
          document.subject.toLowerCase().contains(query) ||
          document.fileType.toLowerCase().contains(query) ||
          document.extension.toLowerCase().contains(query);
    }).toList();
  }

  // ============================================================
  // ADD MENU
  // ============================================================

  Future<void> _showAddMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'What would you like to add?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // ADD NOTE
                // ==================================================
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.note_outlined)),
                  title: const Text('Note'),
                  subtitle: const Text('Create a new study note'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    Future.delayed(const Duration(milliseconds: 350), () {
                      if (!mounted) return;

                      _addNote();
                    });
                  },
                ),

                const SizedBox(height: 8),

                // ==================================================
                // ADD DOCUMENT
                // ==================================================
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.description_outlined),
                  ),
                  title: const Text('Document'),
                  subtitle: const Text('Upload a document from your device'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    // Wait until the bottom sheet has completely
                    // closed before opening the Android file picker.
                    Future.delayed(const Duration(milliseconds: 350), () {
                      if (!mounted) return;

                      _pickDocument();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ADD NOTE
  // ============================================================

  Future<void> _addNote() async {
    if (!mounted) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _NoteDialog(),
    );

    if (!mounted || result == null) {
      return;
    }

    // Wait for the dialog route to finish.
    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    setState(() {
      _notes.add({
        'title': result['title'] ?? '',
        'subject': result['subject'] ?? 'General',
        'content': result['content'] ?? '',
      });
    });

    _showMessage('Note added successfully.');
  }

  // ============================================================
  // EDIT NOTE
  // ============================================================

  Future<void> _editNote(int index) async {
    if (index < 0 || index >= _notes.length) {
      return;
    }

    final note = _notes[index];

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NoteDialog(
        initialTitle: note['title'],
        initialSubject: note['subject'],
        initialContent: note['content'],
        isEditing: true,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted || index >= _notes.length) {
      return;
    }

    setState(() {
      _notes[index] = {
        'title': result['title'] ?? '',
        'subject': result['subject'] ?? 'General',
        'content': result['content'] ?? '',
      };
    });

    _showMessage('Note updated successfully.');
  }

  // ============================================================
  // DELETE NOTE
  // ============================================================

  Future<void> _deleteNote(int index) async {
    if (index < 0 || index >= _notes.length) {
      return;
    }

    final note = _notes[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text(
            'Are you sure you want to delete '
            '"${note['title'] ?? 'this note'}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
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

    await Future<void>.delayed(const Duration(milliseconds: 100));

    if (!mounted || index >= _notes.length) {
      return;
    }

    setState(() {
      _notes.removeAt(index);
    });

    _showMessage('Note deleted.');
  }

  // ============================================================
  // SHOW NOTE DETAILS
  // ============================================================

  Future<void> _showNoteDetails(Map<String, String> note) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(note['title'] ?? 'Note'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note['subject'] ?? 'General',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(note['content'] ?? ''),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PICK DOCUMENT
  // ============================================================

  Future<void> _pickDocument() async {
    // Prevent multiple file pickers from opening.
    if (_isPickingDocument) {
      return;
    }

    if (!mounted) {
      return;
    }

    _isPickingDocument = true;

    try {
      // ========================================================
      // OPEN ANDROID FILE PICKER
      // ========================================================

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'xls',
          'xlsx',
          'txt',
          'csv',
        ],
        allowMultiple: false,
        withData: false,
      );

      // User cancelled the file picker.
      if (!mounted || result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.single;

      // ========================================================
      // CHECK FILE PATH
      // ========================================================

      final sourcePath = pickedFile.path;

      if (sourcePath == null || sourcePath.trim().isEmpty) {
        _showMessage('Unable to access the selected document.');
        return;
      }

      // ========================================================
      // ASK FOR SUBJECT
      // ========================================================

      final subject = await _askForDocumentSubject();

      if (!mounted || subject == null) {
        return;
      }

      // ========================================================
      // IMPORTANT
      //
      // Wait for the keyboard and subject dialog to completely
      // disappear before continuing.
      // ========================================================

      await Future<void>.delayed(const Duration(milliseconds: 400));

      if (!mounted) {
        return;
      }

      // ========================================================
      // COPY FILE
      // ========================================================

      final savedPath = await _copyDocumentToAppStorage(
        sourcePath,
        pickedFile.name,
      );

      if (!mounted) {
        return;
      }

      if (savedPath == null) {
        _showMessage('Could not save the selected document.');
        return;
      }

      // ========================================================
      // CREATE DOCUMENT MODEL
      // ========================================================

      final extension = pickedFile.extension?.toLowerCase() ?? '';

      final document = DocumentModel(
        name: pickedFile.name,
        subject: subject.trim().isEmpty ? 'General' : subject.trim(),
        path: savedPath,
        extension: extension,
        size: pickedFile.size,
      );

      // ========================================================
      // WAIT FOR FILE OPERATION / ROUTE TO SETTLE
      // ========================================================

      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (!mounted) {
        return;
      }

      // ========================================================
      // VERY IMPORTANT
      //
      // Schedule the setState for the next Flutter frame.
      //
      // This avoids rebuilding the NotesScreen while Flutter is
      // still processing the dialog/keyboard route transition.
      // ========================================================

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _documents.add(document);
        });

        // Schedule the SnackBar after the rebuild.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          _showMessage('${pickedFile.name} added successfully.');
        });
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage('Could not add the document: $e');
    } finally {
      _isPickingDocument = false;
    }
  }

  // ============================================================
  // DOCUMENT SUBJECT DIALOG
  // ============================================================

  Future<String?> _askForDocumentSubject() async {
    final controller = TextEditingController();

    try {
      if (!mounted) {
        return null;
      }

      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Document Subject'),

            content: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g. Programming',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            actions: [
              // ==================================================
              // CANCEL
              // ==================================================
              TextButton(
                onPressed: () {
                  // Remove focus first.
                  FocusManager.instance.primaryFocus?.unfocus();

                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),

              // ==================================================
              // CONTINUE
              // ==================================================
              FilledButton(
                onPressed: () {
                  final subject = controller.text.trim();

                  // IMPORTANT:
                  //
                  // Remove keyboard focus BEFORE closing
                  // the dialog.
                  //
                  // This is specifically to prevent:
                  //
                  // _dependents.isEmpty
                  //
                  // and:
                  //
                  // Tried to build dirty widget in the wrong
                  // build scope.
                  //

                  FocusManager.instance.primaryFocus?.unfocus();

                  Navigator.of(dialogContext).pop(subject);
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      // ========================================================
      // WAIT FOR DIALOG / KEYBOARD TRANSITION
      // ========================================================

      await Future<void>.delayed(const Duration(milliseconds: 300));

      return result;
    } finally {
      controller.dispose();
    }
  }

  // ============================================================
  // COPY DOCUMENT TO APP STORAGE
  // ============================================================

  Future<String?> _copyDocumentToAppStorage(
    String sourcePath,
    String fileName,
  ) async {
    try {
      final appDirectory = await getApplicationDocumentsDirectory();

      final documentsDirectory = Directory(
        '${appDirectory.path}/student_planner_documents',
      );

      if (!await documentsDirectory.exists()) {
        await documentsDirectory.create(recursive: true);
      }

      String destinationPath = '${documentsDirectory.path}/$fileName';

      File destinationFile = File(destinationPath);

      // ========================================================
      // CREATE UNIQUE NAME IF FILE ALREADY EXISTS
      // ========================================================

      if (await destinationFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final dotIndex = fileName.lastIndexOf('.');

        if (dotIndex > 0) {
          final name = fileName.substring(0, dotIndex);

          final extension = fileName.substring(dotIndex);

          destinationPath =
              '${documentsDirectory.path}/'
              '${name}_$timestamp$extension';
        } else {
          destinationPath =
              '${documentsDirectory.path}/'
              '${fileName}_$timestamp';
        }

        destinationFile = File(destinationPath);
      }

      // ========================================================
      // CHECK SOURCE
      // ========================================================

      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        return null;
      }

      // ========================================================
      // COPY
      // ========================================================

      final copiedFile = await sourceFile.copy(destinationPath);

      return copiedFile.path;
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DELETE DOCUMENT
  // ============================================================

  Future<void> _deleteDocument(int index) async {
    if (index < 0 || index >= _documents.length) {
      return;
    }

    final document = _documents[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text(
            'Are you sure you want to delete '
            '"${document.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
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

    try {
      final file = File(document.path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Continue removing the document from the list.
    }

    if (!mounted || index >= _documents.length) {
      return;
    }

    setState(() {
      _documents.removeAt(index);
    });

    _showMessage('Document deleted.');
  }

  // ============================================================
  // SHOW DOCUMENT DETAILS
  // ============================================================

  Future<void> _showDocumentDetails(DocumentModel document) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            document.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DocumentDetailRow(label: 'Subject', value: document.subject),

                const SizedBox(height: 12),

                _DocumentDetailRow(label: 'Type', value: document.fileType),

                const SizedBox(height: 12),

                _DocumentDetailRow(
                  label: 'Size',
                  value: document.formattedSize,
                ),

                const SizedBox(height: 12),

                _DocumentDetailRow(label: 'File', value: document.name),
              ],
            ),
          ),

          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
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

    // Schedule the SnackBar on the next frame so it does not
    // interfere with a route/dialog rebuild.
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
  // DOCUMENT ICON
  // ============================================================

  IconData _documentIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;

      case 'doc':
      case 'docx':
        return Icons.description_outlined;

      case 'ppt':
      case 'pptx':
        return Icons.slideshow_outlined;

      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;

      case 'txt':
      case 'csv':
        return Icons.text_snippet_outlined;

      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final notes = _filteredNotes;
    final documents = _filteredDocuments;

    return Scaffold(
      appBar: AppBar(title: const Text('Notes & Documents')),

      body: Column(
        children: [
          // ======================================================
          // SEARCH
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) {
                if (!mounted) return;

                setState(() {
                  _searchQuery = value;
                });
              },

              decoration: InputDecoration(
                hintText: 'Search notes and documents...',

                prefixIcon: const Icon(Icons.search),

                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          if (!mounted) return;

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,

                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),

              children: [
                // ==================================================
                // NOTES HEADER
                // ==================================================
                const Text(
                  'Notes',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // NOTES LIST
                // ==================================================
                if (notes.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No notes found.')),
                    ),
                  )
                else
                  ...List.generate(notes.length, (index) {
                    final note = notes[index];

                    final realIndex = _notes.indexOf(note);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),

                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.note_outlined),
                        ),

                        title: Text(
                          note['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(
                          '${note['subject'] ?? 'General'}\n'
                          '${note['content'] ?? ''}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        isThreeLine: true,

                        onTap: () {
                          _showNoteDetails(note);
                        },

                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editNote(realIndex);
                            }

                            if (value == 'delete') {
                              _deleteNote(realIndex);
                            }
                          },

                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                // ==================================================
                // DOCUMENT HEADER
                // ==================================================
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      '${documents.length}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==================================================
                // DOCUMENT LIST
                // ==================================================
                if (documents.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),

                      child: Column(
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 48,
                            color: Colors.grey[600],
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'No documents uploaded yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Tap + to upload your '
                            'first document.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),

                          const SizedBox(height: 16),

                          FilledButton.icon(
                            onPressed: _isPickingDocument
                                ? null
                                : _pickDocument,

                            icon: const Icon(Icons.upload_file),

                            label: const Text('Upload Document'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...List.generate(documents.length, (index) {
                    final document = documents[index];

                    final realIndex = _documents.indexOf(document);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),

                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(_documentIcon(document.extension)),
                        ),

                        title: Text(
                          document.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(
                          '${document.subject} • '
                          '${document.fileType} • '
                          '${document.formattedSize}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        onTap: () {
                          _showDocumentDetails(document);
                        },

                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'details') {
                              _showDocumentDetails(document);
                            }

                            if (value == 'delete') {
                              _deleteDocument(realIndex);
                            }
                          },

                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'details',
                              child: Text('View Details'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),

      // ==========================================================
      // FLOATING ADD BUTTON
      // ==========================================================
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================
// DOCUMENT DETAIL ROW
// ============================================================

class _DocumentDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DocumentDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        Expanded(child: Text(value)),
      ],
    );
  }
}

// ============================================================
// NOTE DIALOG
// ============================================================

class _NoteDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialSubject;
  final String? initialContent;
  final bool isEditing;

  const _NoteDialog({
    this.initialTitle,
    this.initialSubject,
    this.initialContent,
    this.isEditing = false,
  });

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _titleController;

  late final TextEditingController _subjectController;

  late final TextEditingController _contentController;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle ?? '');

    _subjectController = TextEditingController(
      text: widget.initialSubject ?? '',
    );

    _contentController = TextEditingController(
      text: widget.initialContent ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SAVE NOTE
  // ==========================================================

  void _saveNote() {
    final title = _titleController.text.trim();

    final subject = _subjectController.text.trim();

    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a note title.';
      });

      return;
    }

    if (content.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter some note content.';
      });

      return;
    }

    // Remove keyboard focus BEFORE closing.
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop({
      'title': title,
      'subject': subject.isEmpty ? 'General' : subject,
      'content': content,
    });
  }

  // ==========================================================
  // BUILD NOTE DIALOG
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Note' : 'Add Note'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // ERROR MESSAGE
            // ==================================================
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 16),
            ],

            // ==================================================
            // TITLE
            // ==================================================
            TextField(
              controller: _titleController,

              autofocus: !widget.isEditing,

              textInputAction: TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Note title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),

              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // ==================================================
            // SUBJECT
            // ==================================================
            TextField(
              controller: _subjectController,

              textInputAction: TextInputAction.next,

              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // CONTENT
            // ==================================================
            TextField(
              controller: _contentController,

              maxLines: 6,

              decoration: const InputDecoration(
                labelText: 'Note content',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),

              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
          ],
        ),
      ),

      actions: [
        // ==================================================
        // CANCEL
        // ==================================================
        TextButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();

            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),

        // ==================================================
        // SAVE
        // ==================================================
        FilledButton(
          onPressed: _saveNote,
          child: Text(widget.isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
