import 'package:cloud_firestore/cloud_firestore.dart';

class CourseUserList {
  final String id;
  final List<String>? userIds;

  CourseUserList({
    required this.id,
    this.userIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds ?? []
    };
  }

  static CourseUserList fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return CourseUserList(
      id: doc.id,
      userIds: map['userIds'].cast<String>() ?? [],
    );
  }
}