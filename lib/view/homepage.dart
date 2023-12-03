import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:schedulink/controller/notifications_service.dart';
import 'package:schedulink/view/notification_view.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'schedule.dart';
import 'task_list.dart';
import 'add_deadline_view.dart';
import 'add_course_view.dart';

import 'package:flutter_timezone/flutter_timezone.dart';
import '../model/course.dart';
import '../controller/schedule_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Course>> getCourses() async {
    ScheduleService scheduleService = ScheduleService();
    return await scheduleService.fetchCourses();
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  @override
  void initState() {
    super.initState();
    _configureLocalTimeZone();
    NotificationService().initializeNotifications();

    // To initialise the sg
    FirebaseMessaging.instance.getInitialMessage().then((message) {});

    // To initialise when app is not terminated
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        NotificationService().display(message);
      }
    });

    // To handle when app is open in
    // user divide and heshe is using it
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("on message opened app");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              title: const Text("Schedulink"),
              centerTitle: true,
              // ------- LOGOUT BUTTON
              leading: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {/* logout */},
              ),
              actions: [
                // ------- PROFILE BUTTON
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {/* view user profile */},
                ),

                // ------- MESSAGE BUTTON
                IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {/* go to messages */},
                ),
              ]),
          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 180)),
                      onPressed: () {
                        // load course data before opening page.
                        getCourses().then((value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCourseView(
                                      courses: value,
                                    )),
                          );
                        });
                        // Navigator.push(context, MaterialPageRoute(
                        //     builder: (context) => AddCourseView()),
                        // );
                      },
                      child: const Text('Add Course',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 180)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddDeadlineView()),
                      ),
                      child: const Text('Add Task',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 180)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Schedule()),
                        );
                      },
                      child: const Text('Course \nSchedule',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 180)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TaskList()),
                        );
                      },
                      child: const Text('Upcoming \nDue Dates',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 180)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationList()),
                      );
                    },
                    child: const Text('Upcoming \nNotifications',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20)),
                  ),
                ]),
          )),
    );
  }
}
