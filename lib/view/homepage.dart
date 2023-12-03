import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:time_planner/time_planner.dart';

import 'schedule.dart';
import 'task_list.dart';
// ignore: unused_import
import 'add_deadline_view.dart';
import 'add_course_view.dart';
import 'course_info.dart';

import '../model/course.dart';
import '../model/task.dart';
import '../controller/schedule_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScheduleService scheduleService = ScheduleService();

  Future<List<Course>> getCourses() async {
    return await scheduleService.fetchCourses();
  }

  Future<List<Map<Course, dynamic>>> getScheduleInfo() async {
    return await scheduleService.getUserSchedule();
  }

  Future<List<DeadlineTask>> getDeadlineList() async {
    return await scheduleService.getDeadlineTaskList();
  }

  List<TimePlannerTask> tasks = [];
  List<Map<Course, dynamic>> userCourses = [];

  @override
  void initState() {
    super.initState();
    getScheduleInfo().then((courses) {
      setState(() {
        userCourses = courses;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    tasks = getCourseInfo();
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMMd().format(DateTime.now())),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {/* profile */},
          ),

          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Course/Deadline',
            onPressed: () {
              getCourses().then((value) {
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context) => AddCourseView(courses: value,)),
              );});
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
         child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: TextButton(
              style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 20, color: Colors.white)),
              onPressed: () {
                getScheduleInfo().then((value) {
                  Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => Schedule(userCourses: value)),
                  );
                });
              },
              child: const Text('Schedule', style: TextStyle(color: Colors.white)),
              )
            ),

            Expanded(child: TextButton(
              style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
              onPressed: () {
                getDeadlineList().then((value) {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TaskList(userDeadlines: value)),
                  );
                });
              },
              child: const Text('Deadlines', style: TextStyle(color: Colors.white))),
              ),
          ],)),

      body: TimePlanner(
        style: TimePlannerStyle(
            cellHeight: 70,
            cellWidth: (MediaQuery.of(context).size.width ~/ 6) * 5,
            showScrollBar: true),
        startHour: 0,
        endHour: 23,
        currentTimeAnimation: false,
        use24HourFormat: true,
        headers: [TimePlannerTitle(title: "")],
        tasks: tasks,
      ),
    ));
  }

  List<TimePlannerTask> getCourseInfo() {
    List<TimePlannerTask> listOfTasks = [];

    // get the current day of the week
    String weekday = DateFormat('EEEE').format(DateTime.now());

    // format current day of the week to match how it's stored in Course
    if (weekday == "Monday") { weekday = "M"; }
    if (weekday == "Tuesday") { weekday = "T"; }
    if (weekday == "Wednesday") { weekday = "W"; }
    if (weekday == "Thursday") { weekday = "R"; }
    if (weekday == "Friday") { weekday = "F"; }

    for (var element in userCourses) {
      element.forEach((key, value) {
        if (key.daysOfWeek.contains(weekday)) {
          listOfTasks.add(getSlot(key, key.course, int.parse(key.startTime), int.parse(key.endTime), key.location, value));
        }
      });
    }
    return listOfTasks;
  }

  TimePlannerTask getSlot(Course course, String name, int startTime, int endTime, String location, dynamic value) {

    DateTime start = DateTime(1,1,1,int.parse(startTime.toString().substring(0, 2)),int.parse(startTime.toString().substring(2)));
    DateTime end = DateTime(1,1,1,int.parse(endTime.toString().substring(0, 2)),int.parse(endTime.toString().substring(2)));
    int duration = end.difference(start).inMinutes;

    return TimePlannerTask(
      color: Color(value).withOpacity(1), // background color for task
      dateTime: TimePlannerDateTime(day: 0, hour: start.hour, minutes: start.minute),
      minutesDuration: duration, // Minutes duration of task
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => CourseInfo(course: course)));
      },
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "$name\n$location\n ${DateFormat.jm().format(start)} - ${DateFormat.jm().format(end)}",
          style: const TextStyle(color: Colors.black, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ));
  }
}
