import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../model/course.dart';
import 'package:time_planner/time_planner.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class Schedule extends StatefulWidget {
  
  final List<Map<Course, dynamic>> userCourses;
  const Schedule({super.key,required this.userCourses});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {

  var pdf = pw.Document();
  final ExportDelegate exportDelegate = ExportDelegate();
  ScreenshotController screenshotController = ScreenshotController();

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
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'PDF',
              onPressed: () async {
                await screenshotController.capture().then((screenshot) async {
                  await createPDF(screenshot!);
                  savePDF();
                }).catchError((onError) {
                  // ignore: avoid_print
                  print(onError);
                });
              },
            )
          ]),
      body: Screenshot(
          controller: screenshotController,
          child: TimePlanner(
            style: TimePlannerStyle(
              cellWidth: (MediaQuery.of(context).size.width ~/ 6),
              cellHeight: 50,
              //showScrollBar: true
            ),
            startHour: 8, // time will be start at this hour on table
            endHour: 21, // time will be end at this hour on table
            currentTimeAnimation: false,
            use24HourFormat: true,
            headers: const [
              // each header is a column and a day
              TimePlannerTitle(
                title: "MON",
              ),
              TimePlannerTitle(
                title: "TUES",
              ),
              TimePlannerTitle(
                title: "WED",
              ),
              TimePlannerTitle(
                title: "THURS",
              ),
              TimePlannerTitle(
                title: "FRI",
              ),
            ],
            tasks: tasks,
          )),
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

  createPDF(Uint8List img) async {
    pw.Image screenshot = pw.Image(pw.MemoryImage(img));
    pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Center(child: screenshot),
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> savePDF() async {
    final output = await getApplicationSupportDirectory();
    var filePath = "${output.path}/Schedule.pdf";
    final file = File(filePath);

    file.writeAsBytesSync(await pdf.save());
    // ignore: avoid_print
    print(filePath);
    OpenFile.open(filePath);
    pdf = pw.Document();
  }
}
