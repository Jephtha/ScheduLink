// ignore_for_file: unused_import

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/course.dart';
import 'package:time_planner/time_planner.dart';

class Timetable extends StatefulWidget {
  
  final List<Map<Course, dynamic>> userCourses;
  const Timetable({super.key,required this.userCourses});

  @override
  State<Timetable> createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {

  late List<TimePlannerTask> tasks = getCourseInfo();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(
          title: const Text('Schedule'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).pop();
            },
          )),
      body:
        TimePlanner(
          style: TimePlannerStyle(
            cellHeight: 50,
            cellWidth: (MediaQuery.of(context).size.width ~/ 6)*5,
            showScrollBar: true
          ),
          startHour: DateTime.now().hour, // time will be start at this hour on table
          endHour: 23, // time will be end at this hour on table
          currentTimeAnimation: true,
          use24HourFormat: true,
          headers: const [TimePlannerTitle(title: "TODAY")],
            tasks: tasks,
          ),
    ));
  }

  List<TimePlannerTask> getCourseInfo() {
    List<TimePlannerTask> listOfTasks = [];
    print(widget.userCourses);

      for (var element in widget.userCourses) {
        //print(element.keys);
        element.forEach((key, value) {
          String daysOfWeek = key.daysOfWeek;
          for(var i=0; i < daysOfWeek.length; i++){
            listOfTasks.add(getSlot(key.course,int.parse(key.startTime),int.parse(key.endTime),key.location,daysOfWeek[i],value));
          }
        });
    }
    return listOfTasks;
  }

  TimePlannerTask getSlot(String name, int startTime, int endTime, String location, String dayString, dynamic value) {

    int day = 0;
    if(dayString=="T") { day=1; }
    if(dayString=="W") { day=2; }
    if(dayString=="R") { day=3; }
    if(dayString=="F") { day=4; }

    DateTime start = DateTime(1,1,1,int.parse(startTime.toString().substring(0,2)),int.parse(startTime.toString().substring(2)));
    DateTime end = DateTime(1,1,1,int.parse(endTime.toString().substring(0,2)),int.parse(endTime.toString().substring(2)));
    int duration = end.difference(start).inMinutes;

    return TimePlannerTask(
      color: Color(value).withOpacity(1), // background color for task
      dateTime: TimePlannerDateTime(day: day, hour: int.parse(startTime.toString().substring(0,2)), minutes: int.parse(startTime.toString().substring(2))),
      minutesDuration: duration, // Minutes duration of task
      //onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "$name\n$location",
          style: const TextStyle(color: Colors.black, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ));
  }
}