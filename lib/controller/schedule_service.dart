import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

import '../model/user_info.dart';
import '../model/course.dart';
import '../model/course_user_list.dart';
import '../model/task.dart';


class ScheduleService {
  final currentUser = FirebaseAuth.instance.currentUser;

  final CollectionReference courseCollection;
  final CollectionReference deadlineCollection;
  final DocumentReference userInfoDocument;

  ScheduleService()
      : courseCollection = FirebaseFirestore.instance.collection('courses'),
        userInfoDocument = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid),
        deadlineCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('deadlineTasks');


  Future<List<Course>> fetchCourses() async {
    final String response = await rootBundle.loadString('assets/courses.json');

    // Use the compute function to run parseCourses in a separate isolate.
    return compute(parseCourses, response);
  }

  List<Course> parseCourses(String response) {
    final parsed = jsonDecode(response) as Map<String, dynamic>;
    final parsedCourses = parsed["courses"] as List;

    return parsedCourses.map<Course>((json) => Course.fromJson(json)).toList();
  }

  Future<List<String>> getCourseUserList(String id) async {
   final DocumentSnapshot doc = await courseCollection.doc(id).get();
   if (doc.exists) {
     print("yes");
     return CourseUserList.fromMap(doc).userIds!;
   }
   else {
     CourseUserList u = CourseUserList(id: id);
     await courseCollection.doc(id).set(u.toMap());
     print("no");
     return [];
   }
  }

  Future<String> addUser2Course(String course, String user) async {
    // CourseUserList cl = await getCourseUserList(course);
    // List<String> users = cl.userIds!;
    List<String> users = await getCourseUserList(course);
    if (!users.contains(user)) {
      users.add(user);
    }
    else {
      return "failure";
    }
    CourseUserList courseusers = CourseUserList(id: course, userIds: users);
    await addUserListToCourse(courseusers);
    return "success";
  }

  Future<void> addUserListToCourse(CourseUserList course) async {
     await courseCollection.doc(course.id)
        .set({'userIds': course.userIds}, SetOptions(merge: true)).then((_) {
          print("success adding users to courses");
        });
  }

  Future<void> addUser(UserInfo userInfo) async {
    await userInfoDocument.set(userInfo.toMap()).then((_) {
      print("success adding user");
    });
  }

  Future<void> addCoursesList2User(List<String> courseList) async {
    await userInfoDocument
        .set({'userCourses': courseList}, SetOptions(merge: true)).then((_) {
      print("success adding courses to user");
    });
  }

  Future<UserInfo> getUserCourseList() async {
    return await userInfoDocument
        .get()
        .then((value) => UserInfo.fromMap(value));
  }

  Future<String> addCourse2User(String course) async {
    UserInfo userInfo = await getUserCourseList();
    List<String> courses = userInfo.userCourses!;
    if (!courses.contains(course)) {
      courses.add(course);
    }
    else {
      return "failure";
    }

    await addCoursesList2User(courses);
    return "success";
  }

  Future<void> removeCourseFromUser(String course) async {
    UserInfo userInfo = await getUserCourseList();
    List<String> courses = userInfo.userCourses!;
    courses.remove(course);
    await addCoursesList2User(courses);
  }

  Future<void> updateUserInfo (UserInfo user) async {
    return await userInfoDocument.update(user.toMap());
  }

  Future<String> addDeadline(DeadlineTask deadline) async {
    DocumentReference deadlineRef = await deadlineCollection.add(deadline.toMap());
    return deadlineRef.id;
  }

  Future<DeadlineTask> getDeadlineTask(DeadlineTask deadline) async {
    return deadlineCollection
        .doc(deadline.id)
        .get()
        .then((value) => DeadlineTask.fromMap(value));
  }

  // Future<void> updateDeadlineTask(DeadlineTask deadline) async {
  //   return await deadlineCollection.doc(deadline.id).update(deadline.toMap());
  // }

  Future<void> updateDeadlineTask(DeadlineTask deadline, String id) async {
    return await deadlineCollection.doc(id).update(deadline.toMap());
  }

  Future<void> deleteDeadlineTask(DeadlineTask deadline) async {
    return await deadlineCollection.doc(deadline.id).delete();
  }

  Future<List<DeadlineTask>> getDeadlineTaskList() async {
    QuerySnapshot snapshot = await deadlineCollection.get();
    List<DeadlineTask> deadlineList =
        snapshot.docs.map((doc) => DeadlineTask.fromMap(doc)).toList();

    return deadlineList;
  }
}
