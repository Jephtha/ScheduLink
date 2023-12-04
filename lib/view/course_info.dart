import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
<<<<<<< HEAD
import 'package:schedulink/view/user_profiles.dart';
=======
>>>>>>> 955f6ab416815cccfa28b1801d3c44b30bb6f225

import 'user_profiles.dart';
import '../model/course.dart';
import '../model/user_info.dart';
import '../controller/schedule_service.dart';

class CourseInfo extends StatefulWidget {
  final Course course;
  const CourseInfo({super.key, required this.course});

  @override
  State<CourseInfo> createState() => _CourseInfoState();
}

class _CourseInfoState extends State<CourseInfo> {
  ScheduleService scheduleService = ScheduleService();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.course),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: getCourseInfo(widget.course),
    );
  }

  Future<UserInfo> getUserInfo(String userId) async {
    UserInfo userInfo = await scheduleService.getUserInfoFromId(userId);

    return userInfo;
  }

  Widget getCourseInfo(Course course) {
    DateTime start = DateTime(
        1,
        1,
        1,
        int.parse(course.startTime.toString().substring(0, 2)),
        int.parse(course.startTime.toString().substring(2)));
    DateTime end = DateTime(
        1,
        1,
        1,
        int.parse(course.endTime.toString().substring(0, 2)),
        int.parse(course.endTime.toString().substring(2)));

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width,
      ),
      width: MediaQuery.sizeOf(context).width,
      color: Colors.blueGrey,
      child: Card(
        color: Colors.white38,
        shadowColor: Colors.grey,
        //margin: EdgeInsets.only(top: 100),
        elevation: 15.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
            padding: EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                  text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                    TextSpan(
                        text: "Course: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: '${course.course}-${course.section}'),
                    TextSpan(
                        text: "\nName: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: course.description),
                    TextSpan(
                        text: "\nCRN: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: course.crn),
                    TextSpan(
                        text: "\nClasses: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            "${course.daysOfWeek}, ${DateFormat.jm().format(start)}-${DateFormat.jm().format(end)}"),
                    TextSpan(
                        text: "\nLocation: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: course.location),
                    TextSpan(
                        text: "\nUsers registered for this course: ",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
              SizedBox(
                height: 10,
              ),
              IconButton(
                icon: Icon(
                  Icons.people,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Navigate to the new page when the icon is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CoursesInfo(
                        course: course,
                      ),
                    ),
                  );
                },
              ),
            ])),
      ),
    );
  }
}
