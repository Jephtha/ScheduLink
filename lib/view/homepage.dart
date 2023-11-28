import 'package:flutter/material.dart';

import 'schedule.dart';
import 'task_list.dart';
import 'add_deadline_view.dart';
import 'add_course_view.dart';

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
                        getCourses().then((value) {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AddCourseView(courses: value,)),
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
                      onPressed: () => Navigator.push(context,
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
                ]),
          )),
    );
  }
}
