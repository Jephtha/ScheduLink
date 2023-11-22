import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String? id;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final List<String> userIds;

  Course({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.userIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'description': description,
      'userIds': userIds
    };
  }

  static Course fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      startTime: map['startTime'].toDate() ?? DateTime.now(),
      endTime: map['endTime'].toDate() ?? DateTime.now(),
      description: map['description'] ?? '',
      userIds: map['userIds'] ?? [],
    );
  }
}