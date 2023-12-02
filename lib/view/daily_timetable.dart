// ignore_for_file: unused_import

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedulink/view/course_info.dart';
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
          title: const Text('Today'),
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
            cellHeight: 70,
            cellWidth: (MediaQuery.of(context).size.width ~/ 6)*5,
            showScrollBar: true
          ),
          startHour: 0, 
          endHour: 23, 
          currentTimeAnimation: false,
          use24HourFormat: true,
          headers: [TimePlannerTitle(title: DateFormat.yMMMMd().format(DateTime.now()), date: DateFormat.jm().format(DateTime.now()))],
            tasks: tasks,
          ),
    ));
  }

  List<TimePlannerTask> getCourseInfo() {
    List<TimePlannerTask> listOfTasks = [];

    // get the current day of the week
    String weekday = DateFormat('EEEE').format(DateTime.now());

    // format current day of the week to match how it's stored in Course 
    if(weekday=="Monday") { weekday = "M"; }
    if(weekday=="Tuesday") { weekday = "T"; }
    if(weekday=="Wednesday") { weekday = "W"; }
    if(weekday=="Thursday") { weekday = "R"; }
    if(weekday=="Friday") { weekday = "F"; }

      for (var element in widget.userCourses) {
        element.forEach((key, value) {
          String daysOfWeek = key.daysOfWeek;
          for(var i=0; i < daysOfWeek.length; i++){
            if(daysOfWeek[i] == weekday){
              listOfTasks.add(getSlot(key,key.course,int.parse(key.startTime),int.parse(key.endTime),key.location,value));
            }
          }
        });
    }
    return listOfTasks;
  }

  TimePlannerTask getSlot(Course course, String name, int startTime, int endTime, String location, dynamic value) {

    DateTime start = DateTime(1,1,1,int.parse(startTime.toString().substring(0,2)),int.parse(startTime.toString().substring(2)));
    DateTime end = DateTime(1,1,1,int.parse(endTime.toString().substring(0,2)),int.parse(endTime.toString().substring(2)));
    int duration = end.difference(start).inMinutes;

    return TimePlannerTask(
      color: Color(value).withOpacity(1), // background color for task
      dateTime: TimePlannerDateTime(day: 0, hour: start.hour, minutes: start.minute),
      minutesDuration: duration, // Minutes duration of task
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CourseInfo(course: course)),
        );
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