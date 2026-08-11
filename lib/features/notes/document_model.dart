class DocumentModel {
  final String name;
  final String subject;
  final String path;
  final String extension;
  final int size;

  const DocumentModel({
    required this.name,
    required this.subject,
    required this.path,
    required this.extension,
    required this.size,
  });

  String get fileType {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';

      case 'doc':
      case 'docx':
        return 'Word Document';

      case 'ppt':
      case 'pptx':
        return 'PowerPoint';

      case 'xls':
      case 'xlsx':
        return 'Excel';

      case 'txt':
        return 'Text File';

      case 'csv':
        return 'CSV File';

      default:
        return 'Document';
    }
  }

  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    }

    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    }

    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
