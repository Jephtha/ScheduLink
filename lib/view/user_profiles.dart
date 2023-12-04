// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schedulink/model/course.dart';

import '../controller/schedule_service.dart';

class CoursesInfo extends StatefulWidget {
  final Course course;
  const CoursesInfo({super.key, required this.course});

  @override
  State<CoursesInfo> createState() => _CoursesInfoState();
}

class _CoursesInfoState extends State<CoursesInfo> {
  ScheduleService scheduleService = ScheduleService();
  final currentUser = FirebaseAuth.instance.currentUser;
  String name = 'User not picked.';
  String contact = 'User not picked.';
  String? imgUrl;

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
        body: SingleChildScrollView(child: getCourseInfo(widget.course)));
  }

  Container getCourseInfo(Course course) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 800,
            width: 120,
            child: FutureBuilder(
              future: scheduleService
                  .getCourseUserList("${course.course}-${course.section}"),
              builder:
                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    List<String>? users = snapshot.data;
                    // Create buttons for each item in the list
                    return ListView.builder(
                      itemCount: users!.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future:
                              scheduleService.getUserInfoFromId(users[index]),
                          builder: (context, additionalDataSnapshot) {
                            switch (additionalDataSnapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.active:
                              case ConnectionState.waiting:
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              case ConnectionState.done:
                                if (additionalDataSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                        'Error: ${additionalDataSnapshot.error}'),
                                  );
                                }
                                var userInfo = additionalDataSnapshot.data;
                                // Build your UI using the item and additional data
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors
                                          .purple.shade800, // Border color
                                      width: 2.0, // Border width
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(
                                        20.0)), // Optional: BorderRadius for rounded corners
                                  ),
                                  height: 30,
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Action to perform when the button is pressed
                                      setState(() {
                                        name = userInfo.name;
                                        contact = userInfo.contactInfo;
                                        imgUrl = userInfo.profileImg;
                                      });
                                      print(
                                          'Button pressed for ${userInfo.name}');
                                    },
                                    child: Text(
                                      userInfo!.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                );
                            }
                          },
                        );
                      },
                    );
                }
              },
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            height: 410,
            width: 210,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(
                color: Colors.purple, // Border color
                width: 2.0, // Border width
              ),
              borderRadius: BorderRadius.all(Radius.circular(
                  20.0)), // Optional: BorderRadius for rounded corners
            ),
            child: SizedBox(
              height: 400,
              width: 200,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, // Border color
                    width: 2.0, // Border width
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(
                      20.0)), // Optional: BorderRadius for rounded corners
                ),
                child: Center(
                  child: Column(children: [
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 200,
                      width: 300,
                      child: imgUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 200,
                            )
                          : Image.network(imgUrl!),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Name: \n",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: "\nContact Detail: \n",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: contact,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ])),
                  ]),
                ),
              ),
            ),
          ),
        ]));
  }
}
