class ScheduleModel {
  final String id;
  final String day;
  final String time;
  final String subject;
  final String location;
  final String description;

  const ScheduleModel({
    required this.id,
    required this.day,
    required this.time,
    required this.subject,
    required this.location,
    this.description = '',
  });

  // ============================================================
  // CONVERT MODEL TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'time': time,
      'subject': subject,
      'location': location,
      'description': description,
    };
  }

  // ============================================================
  // CREATE MODEL FROM JSON
  // ============================================================

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id']?.toString() ?? '',
      day: json['day']?.toString() ?? 'Monday',
      time: json['time']?.toString() ?? '08:00',
      subject: json['subject']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  // ============================================================
  // CREATE A COPY WITH UPDATED VALUES
  // ============================================================

  ScheduleModel copyWith({
    String? id,
    String? day,
    String? time,
    String? subject,
    String? location,
    String? description,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      day: day ?? this.day,
      time: time ?? this.time,
      subject: subject ?? this.subject,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }
}
