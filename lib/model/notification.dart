import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime deadlineDate;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.deadlineDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadlineDate': deadlineDate,
    };
  }

  static NotificationItem fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadlineDate: map['deadlineDate'].toDate() ?? DateTime.now(),
    );
  }
}
