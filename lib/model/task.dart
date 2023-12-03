import 'package:cloud_firestore/cloud_firestore.dart';

class DeadlineTask {
  final String? id;
  final String name;
  final String course;
  final DateTime dueDate;
  final String description;
  final String priority;
  bool isComplete;

  DeadlineTask({
    this.id,
    required this.name,
    required this.course,
    required this.dueDate,
    required this.description,
    required this.priority,
    required this.isComplete,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
      'dueDate': dueDate,
      'description': description,
      'priority': priority,
      'isComplete': isComplete,
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
      isComplete: map['isComplete'] ?? 'false',
    );
  }
}
