// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedulink/model/course.dart';
import 'package:schedulink/view/courses_info.dart';

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
    return MaterialApp(
      home: Scaffold(
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
          body: SingleChildScrollView(child: getCourseInfo(widget.course))),
    );
  }

  Container getCourseInfo(Course course) {
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
        padding: EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              ])),
          SizedBox(
            height: 00,
          ),
          Row(
            children: [
              Center(
                  child: Text("Classmates:",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ))),
              IconButton(
                icon: Icon(Icons.people),
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
              /*SizedBox(
                width: 100,
                child: FutureBuilder(
                    future: scheduleService.getCourseUserList(
                        "${course.course}-${course.section}"),
                    builder: (context, snapshot) {
                      String text = "";
                      List<String>? users = snapshot.data;
                      if (snapshot.hasData) {
                        return Center(
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.people),
                            onSelected: (String option) async {},
                            itemBuilder: (BuildContext context) {
                              return users!.map((String option) {
                                return PopupMenuItem<String>(
                                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (var i = 0; i < users.length; i++)
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20)),
                                              onPressed: () async {
                                                var userInfo =
                                                    await scheduleService
                                                        .getUserInfoFromId(
                                                            users[i]);
                                                // trigger popup with user info page
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          "Contact User",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        content: Text(
                                                          'Name: ${userInfo.name} \nContact Details: ${userInfo.contactInfo}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text(
                                                                "OK"),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                              child: Text("- $text${users[i]}",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .grey.shade700)),
                                            ),
                                        ]));
                              }).toList();
                            },
                          ),
                        );
                      } else {
                        return Text("Add courses to view course info...");
                      }
                    }),
              ),*/
            ],
          ),
        ]));
  }
}
