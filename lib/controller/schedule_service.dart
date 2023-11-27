import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

import '../model/user_info.dart';
import '../model/course.dart';
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

  Future<DocumentReference<Object?>> addCourse(Course course) async {
    return await courseCollection.add(course.toMap());
  }

  Future<void> addUser(UserInfo userInfo) async {
    await userInfoDocument.set(userInfo.toMap()).then((_) {
      print("success adding user");
    });
  }

  Future<void> addCoursesList2User(List courseList) async {
    await userInfoDocument
        .set({'courseTasks': courseList}, SetOptions(merge: true)).then((_) {
      print("success adding courses to user");
    });
  }

  Future<List<String>> getUserCourseList() async {
    return await userInfoDocument
        .get()
        .then((snapshot) => snapshot.get('courseTasks'));
  }

  Future<void> addCourse2User(String course) async {
    List<String> courses = await getUserCourseList();
    courses.add(course);
    await addCoursesList2User(courses);
  }

  Future<void> removeCourseFromUser(String course) async {
    List<String> courses = await getUserCourseList();
    courses.remove(course);
    await addCoursesList2User(courses);
  }

  Future<DocumentReference<Object?>> addDeadline(DeadlineTask deadline) async {
    return await deadlineCollection.add(deadline.toMap());
  }

  Future<DeadlineTask> getDeadlineTask(DeadlineTask deadline) async {
    return deadlineCollection
        .doc(deadline.id)
        .get()
        .then((value) => DeadlineTask.fromMap(value));
  }

  Future<void> updateDeadlineTask(DeadlineTask deadline, String id) async {
    return await deadlineCollection.doc(id).update(deadline.toMap());
  }

  Future<void> deleteDiary(DeadlineTask deadline) async {
    return await deadlineCollection.doc(deadline.id).delete();
  }

  Future<List<DeadlineTask>> getDeadlineTaskList() async {
    QuerySnapshot snapshot = await deadlineCollection.get();
    List<DeadlineTask> diaryList =
        snapshot.docs.map((doc) => DeadlineTask.fromMap(doc)).toList();

    return diaryList;
  }
}

// class ScheduleService {
//   final currentUser = FirebaseAuth.instance.currentUser;
//
//   final CollectionReference diaryCollection;
//   DiaryService()
//       : diaryCollection = FirebaseFirestore.instance
//       .collection('users')
//       .doc(FirebaseAuth.instance.currentUser!.uid)
//       .collection('diary');
//
//   Future<DocumentReference<Object?>> addDiary(DiaryModel diary) async {
//     if (await diaryExists(diary.date)) {
//       throw Exception('Entry already exists for this date');
//     }
//     return await diaryCollection.add(diary.toMap());
//   }
//
//   Future<bool> diaryExists(DateTime date) async {
//     QuerySnapshot snapshot = await diaryCollection.get();
//     List diaryList = snapshot.docs.map((doc) => DiaryModel.fromMap(doc))
//         .where((element) => element.date == date).toList();
//
//     return diaryList.isNotEmpty;
//   }
//
//   Future<DiaryModel> getDiary(DiaryModel diary) async {
//     return diaryCollection.doc(diary.id).get().then((value) => DiaryModel.fromMap(value));
//   }
//
//   Future<void> updateDiary (DiaryModel diary, String id) async {
//     return await diaryCollection.doc(id).update(diary.toMap());
//   }
//
//   Future<void> deleteDiary(DiaryModel diary) async {
//     return await diaryCollection.doc(diary.id).delete();
//   }
//
//   Stream<List<DiaryModel>> getUserDiaries() {
//     return diaryCollection.snapshots().map(
//             (snapshot) => snapshot.docs.map(
//                 (doc) => DiaryModel.fromMap(doc)).toList());
//   }
//
//   Future<List<DiaryModel>> filteredDiaryList() async {
//     QuerySnapshot snapshot = await diaryCollection.get();
//     List<DiaryModel> diaryList = snapshot.docs.map((doc) => DiaryModel.fromMap(doc)).toList();
//
//     return diaryList;
//   }
//
//   // This function is responsible for uploading images to Firebase.
//   Future<String> uploadImageToFirebase(XFile? image) async {
//     // Check if the image is null (not selected). If so, return immediately.
//     if (image == null) return 'failed';
//
//     // If there's no logged-in user, return immediately.
//     if (currentUser == null) return 'failed';
//
//     String downloadURL = 'failed';
//
//     // Define a reference in Firebase Storage where we want to upload the image.
//     // We are organizing images in a folder named by the user's UID, and the image is named af
//     final firebaseStorageRef = FirebaseStorage.instance.ref()
//         .child('images/${currentUser!.uid}/${image.name}');
//
//     try {
//
//       // Start the upload process to Firebase Storage and wait for it to finish.
//       final uploadTask = await firebaseStorageRef.putFile(File(image.path));
//
//       // Check if the upload was successful.
//       if (uploadTask.state == TaskState.success) {
//
//         // If successful, get the download URL of the uploaded image and print it.
//         downloadURL = await firebaseStorageRef.getDownloadURL();
//         return downloadURL;
//       }
//     } catch (e) { // Handle any errors that might occur during the upload process.
//       // Print the error message.
//       print("Failed to upload image: $e");
//       throw Exception("Failed to upload image: $e");
//     }
//     return downloadURL;
//   }
// }
