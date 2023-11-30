import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'temp_task.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<TempTask> tasksList = getTaskList();
  int lastDate = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Deadlines'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add Task',
          iconSize: 35.0,
          onPressed: () {/* will direct to "Add Task" page */},
        ),
      ]),
      body: SingleChildScrollView(
          child: Column(
        children: [
          for (var i = 0; i < tasksList.length; i++) ...[
            checkDate(tasksList[i]),
            createTask(tasksList[i]),
            const Divider(height: 0),
          ]
        ],
      )),
    );
  }

  Container checkDate(TempTask task) {
    String date = DateFormat('MMddyyyy').format(task.dueDate);
    if (lastDate != int.parse(date)) {
      lastDate = int.parse(date);
      // ignore: avoid_unnecessary_containers
      return Container(
          child: ListTile(
        tileColor: Colors.grey.shade300,
        title: Text(
          "${DateFormat('LLLL').format(task.dueDate)} ${task.dueDate.day}, ${task.dueDate.year}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ));
    } else {
      return Container();
    } // return empty container and move onto next task
  }

  ListTile createTask(TempTask task) {
    Color priorityColor = Colors.green;
    Color backgroundColor = Colors.white;
    if (task.priority == 1) { priorityColor = Colors.amber; }
    if (task.priority == 2) { priorityColor = Colors.red; }
    if (task.isComplete) { backgroundColor = Colors.grey.shade400; }

        Text titleText = Text.rich(TextSpan(children: <TextSpan>[

      // add flag for assignments due in < 24 hours
      if (0 < task.dueDate.difference(DateTime.now()).inHours && task.dueDate.difference(DateTime.now()).inHours < 24 && !task.isComplete)
        TextSpan(text: "DUE SOON!\n", style: TextStyle(color: Colors.red)),

      // task name and course 
      TextSpan(text: "${task.name} - ${task.courseName}", style: TextStyle(fontWeight: FontWeight.bold))]
    ),);

    // the "body" text - includes task due date and descrption 
    Text taskText = Text.rich(TextSpan(
      children: <TextSpan>[
        TextSpan(text: "Due: ${DateFormat('LLLL').format(task.dueDate)} ${task.dueDate.day}, ${task.dueDate.year} at ${task.dueDate.hour}:${task.dueDate.minute}"),
        if (task.description.isNotEmpty) 
          TextSpan(text: "\n${task.description}"),]
    ));

    // highlight missed deadlines/overdue tasks  
    if (DateTime.now().isAfter(task.dueDate) && !task.isComplete) {
      backgroundColor = Colors.red.shade100;
    }

    return ListTile(
      tileColor: backgroundColor,
      title: titleText,
      subtitle: taskText,
      
      leading: Icon(Icons.warning, color: priorityColor), // priority icon
      
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [ // checkbox
        Checkbox(
          value: task.isComplete,
          onChanged: (bool? value) {
            setState(() {
              task.isComplete = value!;
            });
          },
        )
      ]),
    );
  }
}

List<TempTask> getTaskList() {
  final task1 = TempTask("Final Project", "CS1000",
  "Description of the task will go here. This is what it will look like if the user chooses to add a longer description or make more notes about a deadline",
      DateTime(2023, 11, 10, 23, 59), 3, false);
  final task2 = TempTask("Review Notes", "Math1000", "Review notes for exam",
      DateTime(2023, 12, 08, 11, 59), 1, false);
  final task3 = TempTask("Online Quiz", "CS1001", "Do online quiz",
      DateTime(2023, 11, 29, 23, 59), 2, false);
  late List<TempTask> tasksList = [task1, task2, task3];
  tasksList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return tasksList;
}