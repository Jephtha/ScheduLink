import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedulink/model/course.dart';

class CourseInfo extends StatefulWidget {
  
  final Course course;
  const CourseInfo({super.key,required this.course});

  @override
  State<CourseInfo> createState() => _CourseInfoState();
}

class _CourseInfoState extends State<CourseInfo> {

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
        body: SingleChildScrollView(child: getCourseInfo(widget.course))
      ),
    );
  }
}

//DateTime(1,1,1,int.parse(startTime.toString().substring(0,2)),int.parse(startTime.toString().substring(2))

Container getCourseInfo(Course course){
  
  DateTime start = DateTime(1,1,1,int.parse(course.startTime.toString().substring(0,2)),int.parse(course.startTime.toString().substring(2)));
  DateTime end = DateTime(1,1,1,int.parse(course.endTime.toString().substring(0,2)),int.parse(course.endTime.toString().substring(2)));
  return Container(
    padding: EdgeInsets.all(20.0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Course: ${course.course}-${course.section}"),
      Text("Name: ${course.description}"),
      Text("CRN: ${course.crn}"),
      Text("Classes: ${course.daysOfWeek}, ${DateFormat.jm().format(start)}-${DateFormat.jm().format(end)}"),
      Text("Location: ${course.location}")]
    )
  );
}