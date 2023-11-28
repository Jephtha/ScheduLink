class Course {
  final String subject;
  final String course;
  final String description;
  final String section;
  final String crn;
  final String slot;
  final String daysOfWeek;
  final String startTime;
  final String endTime;
  final String location;

  const Course({
    required this.subject,
    required this.course,
    required this.description,
    required this.section,
    required this.crn,
    required this.slot,
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      subject: json['subject'] as String,
      course: json['course'] as String,
      description: json['description'] as String,
      section: json['section'] as String,
      crn: json['crn'] as String,
      slot: json['slot'] as String,
      daysOfWeek: json['daysOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
    );
  }
}
