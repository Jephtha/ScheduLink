import 'package:cloud_firestore/cloud_firestore.dart';

import 'task.dart';

class UserInfo {
  final String? id;
  final String profileImg;
  final String contactInfo;
  final List<CourseTask> courseTasks;
  final List<DeadlineTask> deadlineTasks;

  UserInfo({
    this.id,
    required this.profileImg,
    required this.contactInfo,
    required this.courseTasks,
    required this.deadlineTasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileImg': profileImg,
      'contactInfo': contactInfo,
      'courseTasks': courseTasks.map((i) => i.toMap()).toList(),
      'deadlineTasks': deadlineTasks.map((i) => i.toMap()).toList(),
    };
  }

  UserInfo fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return UserInfo(
      id: doc.id,
      profileImg: map['profileImg'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      courseTasks: map['courseTasks'].map<CourseTask>((mapString) =>
          CourseTask.fromMap(mapString)).toList() ?? [],
      deadlineTasks: map['deadlineTasks'].map<DeadlineTask>((mapString) =>
          DeadlineTask.fromMap(mapString)).toList() ?? [],
    );
  }
}