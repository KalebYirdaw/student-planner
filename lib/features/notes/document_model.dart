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
    if (extension.isEmpty) {
      return 'Unknown';
    }

    return extension.toUpperCase();
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subject': subject,
      'path': path,
      'extension': extension,
      'size': size,
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      name: json['name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? 'General',
      path: json['path']?.toString() ?? '',
      extension: json['extension']?.toString() ?? '',
      size: json['size'] is int
          ? json['size'] as int
          : int.tryParse(json['size']?.toString() ?? '0') ?? 0,
    );
  }
}
