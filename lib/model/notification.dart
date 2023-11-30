import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String? id;
  final String title;
  final String description;
  final DateTime deadlineDate;
  final String priority;

  NotificationItem({
    this.id,
    required this.title,
    required this.description,
    required this.deadlineDate,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadlineDate': deadlineDate,
      'priority': priority,
    };
  }

  static NotificationItem fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadlineDate: map['deadlineDate'].toDate() ?? DateTime.now(),
      priority: map['priority'] ?? 'low',
    );
  }
}
