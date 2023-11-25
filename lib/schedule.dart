import 'package:flutter/material.dart';
import 'package:schedulink/course.dart';
import 'package:time_planner/time_planner.dart';


class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {

  final course1 = Course("CS1000",001,"Course 1 Description","ENG2004",[[13,14,0],[13,14,2],[9,10,4]],Colors.blue);
  final course2 = Course("CS1001",010,"Course 2 Description","ENG2007",[[10,12,1],[10,12,3]],Colors.red);
  final course3 = Course("MATH1000",100,"Course 3 Description","C2000",[[9,10,0],[9,10,3],[11,12,4]],Colors.orange);
  late List<Course> coursesList = [course1,course2,course3];
  late List<TimePlannerTask> tasks = getWeeklySlot(coursesList);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Schedule'), leading: 
            IconButton(icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () { Navigator.of(context).pop(); },),),

          body: TimePlanner(
            style: TimePlannerStyle(
              cellWidth: (MediaQuery.of(context).size.width~/6),
              showScrollBar: true),
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
            // List of task will be show on the time planner
            tasks: tasks,
          ),
        )
    );
  }
}

List<TimePlannerTask> getWeeklySlot(coursesList){
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
      dateTime: TimePlannerDateTime(day: day, hour: startTime, minutes: 0), 
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