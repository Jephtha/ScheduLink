import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final String? id;
  final String profileImg;
  final String contactInfo;
  final List<String>? courses;

  UserInfo({
    this.id,
    required this.profileImg,
    required this.contactInfo,
    this.courses,
  });

  Map<String, dynamic> toMap() {
    return {
      'profileImg': profileImg,
      'contactInfo': contactInfo,
      'courses': courses ?? []
    };
  }

  UserInfo fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return UserInfo(
      id: doc.id,
      profileImg: map['profileImg'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      courses: map['courses'] ?? [],
    );
  }
}
