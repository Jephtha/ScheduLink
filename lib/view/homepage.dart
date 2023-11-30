import 'package:flutter/material.dart';
import 'package:schedulink/view/daily_timetable.dart';

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

  Future<List<Map<Course, dynamic>>> getScheduleInfo() async {
    ScheduleService scheduleService = ScheduleService();
    return await scheduleService.getUserSchedule();
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
                    onPressed: () {},
                  //onPressed: () {/* view user profile */},
                ),
              ]),

          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(180, 50)),
                    onPressed: () {
                      // load course data before opening page.
                      getCourses().then((value) {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => AddCourseView(courses: value,)),
                        );
                      });                        
                    },
                    child: const Text('Add Course',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(180, 50)),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => const AddDeadlineView()),
                    ),
                    child: const Text('Add Task',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                    ),
                  
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(180, 50)),
                    onPressed: () {
                      getScheduleInfo().then((value) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Schedule(userCourses: value,)),
                        );
                      });
                    },
                    child: const Text('Course \nSchedule',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(180, 50)),
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => const TaskList()),
                      );
                    },
                    child: const Text('Upcoming \nDue Dates',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(180, 50)),
                      onPressed: () {
                        getScheduleInfo().then((value) {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Timetable(userCourses: value,)),
                          );
                        });
                      },
                    child: const Text("Today's Timetable",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20)),
                  ),
                ]),
          )),
    );
  }
}
