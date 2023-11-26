import 'package:cloud_firestore/cloud_firestore.dart';

class DeadlineTask {
  final String? id;
  final String name;
  final String course;
  final DateTime dueDate;
  final String description;
  final String priority;
  final String status;

  DeadlineTask({
    this.id,
    required this.name,
    required this.course,
    required this.dueDate,
    required this.description,
    required this.priority,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
      'dueDate': dueDate,
      'description': description,
      'priority': priority,
      'status': status,
    };
  }

  static DeadlineTask fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return DeadlineTask(
      id: doc.id,
      name: map['name'] ?? '',
      course: map['course'] ?? '',
      dueDate: map['dueDate'].toDate() ?? DateTime.now(),
      description: map['description'] ?? '',
      priority: map['priority'] ?? 'low',
      status: map['status'] ?? 'incomplete',
    );
  }
}

// class CourseTask {
//   final String id;
//   final String name;
//   final DateTime startTime;
//   final DateTime endTime;
//   final String description;
//
//   CourseTask({
//     required this.id,
//     required this.name,
//     required this.startTime,
//     required this.endTime,
//     required this.description,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'startTime': startTime,
//       'endTime': endTime,
//       'description': description,
//     };
//   }
//
//   static CourseTask fromMap(Map<dynamic, dynamic> map) {
//     return CourseTask(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       startTime: map['startTime'].toDate() ?? DateTime.now(),
//       endTime: map['endTime'].toDate() ?? DateTime.now(),
//       description: map['description'] ?? '',
//     );
//   }
// }
