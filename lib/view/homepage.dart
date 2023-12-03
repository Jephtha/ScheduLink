import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:schedulink/view/profile.dart';
import 'package:time_planner/time_planner.dart';

import 'schedule.dart';
import 'task_list.dart';
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
  List<DeadlineTask> userDeadlines = [];
  List<TimePlannerTask> listOfTasks = [];

  @override
  void initState() {
    super.initState();
    getScheduleInfo().then((courses){
    getDeadlineList().then((deadlines) {
      setState(() {
        userCourses = courses;
        userDeadlines = deadlines;
      });
    });});
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
            onPressed: () { 
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Profile()));
            },
          ),

          MenuAnchor(builder:
              (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.add),
              tooltip: 'Add',
            );
          },
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                getCourses().then((value) {
                  Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => AddCourseView(courses: value,)),
                  );});
              },
              child: Text('Add Course'),
            ),

            MenuItemButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => const AddDeadlineView()),
                  );
              },
              child: Text('Add Deadline'),
            ),
          ],
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

      body: getBody(),
    ));
  }

  List<TimePlannerTask> getCourseInfo() {
    // get the current day of the week
    String weekday = DateFormat('EEEE').format(DateTime.now()); 
    // change weekday to "Monday" or "Wednesday", etc., if testing on a day with no tasks 

    // format current day of the week to match how it's stored in Course
    if (weekday == "Monday") { weekday = "M"; }
    if (weekday == "Tuesday") { weekday = "T"; }
    if (weekday == "Wednesday") { weekday = "W"; }
    if (weekday == "Thursday") { weekday = "R"; }
    if (weekday == "Friday") { weekday = "F"; }

    for (var element in userCourses) {
      element.forEach((key, value) {
        if (key.daysOfWeek.contains(weekday)) {
          listOfTasks.add(getClassSlot(key, value));
        }
      });
    }

    if(userDeadlines.isNotEmpty) {
      for (DeadlineTask task in userDeadlines) {
        if ((task.dueDate.day == DateTime.now().day && !task.isComplete)) {
          listOfTasks.add(getDeadlineSlot(task));
        }
      }
    }
    return listOfTasks;
  }

  TimePlannerTask getClassSlot(Course course, dynamic value) {

    DateTime start = DateTime(1,1,1,int.parse(course.startTime.toString().substring(0, 2)),int.parse(course.startTime.toString().substring(2)));
    DateTime end = DateTime(1,1,1,int.parse(course.endTime.toString().substring(0, 2)),int.parse(course.endTime.toString().substring(2)));
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
          "${course.course}\n${course.location}\n ${DateFormat.jm().format(start)} - ${DateFormat.jm().format(end)}",
          style: const TextStyle(color: Colors.black, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ));
  }

  TimePlannerTask getDeadlineSlot(DeadlineTask task) {

    return TimePlannerTask(
      color: Colors.red.shade200, // background color for task
      dateTime: TimePlannerDateTime(day: 0, hour: (task.dueDate.hour), minutes: 0),
      minutesDuration: 60, // Minutes duration of task
      onTap: () {
        getDeadlineList().then((value) {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => TaskList(userDeadlines: value)),
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "${task.course} ${task.name} due at ${DateFormat.jm().format(task.dueDate)}!!",
          style: const TextStyle(color: Colors.black, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ));
  }


  Widget getBody(){
    if(listOfTasks.isNotEmpty){
      return TimePlanner(
        style: TimePlannerStyle(
          cellHeight: 70,
          cellWidth: (MediaQuery.of(context).size.width ~/ 6) * 5,
          showScrollBar: true),
        startHour: 0,
        endHour: 23,
        currentTimeAnimation: true,
        use24HourFormat: true,
        headers: [TimePlannerTitle(title: "")],
        tasks: tasks,
      );
    }
    else {
      return Center(child: SingleChildScrollView(child: Column(children: [
        Text("You have nothing scheduled for today! \nTake it easy, or ",textAlign: TextAlign.center,),
        ElevatedButton(
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddDeadlineView()),
          ),
          child: const Text('Add Task',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20)),
        )
      ])));
    }
  }
}