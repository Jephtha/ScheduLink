import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:schedulink/temp_course.dart';
import 'package:time_planner/time_planner.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';


class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {

  var pdf = pw.Document();
  final ExportDelegate exportDelegate = ExportDelegate();
  late List<TimePlannerTask> tasks = getWeeklySlot();
  ScreenshotController screenshotController = ScreenshotController(); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Schedule'), leading: 
            IconButton(icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () { Navigator.of(context).pop(); },),
            actions: [IconButton(icon: const Icon(Icons.download),
            tooltip: 'PDF',
            onPressed: () async { 
              await screenshotController
                  .capture()
                  .then((screenshot) async {
                await createPDF(screenshot!);
                savePDF();
              }).catchError((onError) {
                // ignore: avoid_print
                print(onError);
              });},)
            ]),

          body: Screenshot(
            controller: screenshotController,
            child:
              TimePlanner(
                style: TimePlannerStyle(
                  cellWidth: (MediaQuery.of(context).size.width~/6),
                  cellHeight: 50,
                  //showScrollBar: true
                ),
                startHour: 8, // time will be start at this hour on table
                endHour: 21, // time will be end at this hour on table
                currentTimeAnimation: false,
                use24HourFormat: true,
                headers: const [ // each header is a column and a day
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
        )
    );
  }

  List<TimePlannerTask> getWeeklySlot(){
    final course1 = TempCourse("CS1000",001,"Course 1 Description","ENG2004",[[13,14,0],[13,14,2],[09,10,4]],Colors.blue);
    final course2 = TempCourse("CS1001",010,"Course 2 Description","ENG2007",[[10,12,1],[10,12,3]],Colors.red);
    final course3 = TempCourse("MATH1000",100,"Course 3 Description","C2000",[[09,10,0],[09,10,3],[11,12,4]],Colors.orange);
    List<TempCourse> coursesList = [course1,course2,course3];

    List<TimePlannerTask> listOfTasks = [];
    for (var i = 0; i < coursesList.length; i++) {
      for (var x = 0; x < coursesList[i].classSections.length; x++) {
        listOfTasks.add(getSlot(coursesList[i].classSections[x],coursesList[i].name,coursesList[i].color));
      }
    }
    return listOfTasks;
  }

  TimePlannerTask getSlot(List<int> courseSlot,String name, Color color){
    int startTime = courseSlot[0];
    int finishTime = courseSlot[1];
    int day = courseSlot[2];
    return TimePlannerTask(
      color: color,  // background color for task

      // day: index of header, monday-friday is 0-4
      dateTime: TimePlannerDateTime(day: day, hour: startTime, minutes: 60), 
      // ^ need to add a check here, parse to see how many minutes past the hour the class starts (ex. 9 or 9:30)
      minutesDuration: (finishTime-startTime)*60, // Minutes duration of task
      onTap: () {},
      child: 
        Padding(padding: const EdgeInsets.all(1),
          child: Text(
            name,
            style: const TextStyle(color: Colors.black, fontSize: 13),
            textAlign: TextAlign.center,
          ),)
    );
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