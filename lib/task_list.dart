import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedulink/task.dart';


class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {

  List<Task> tasksList = getTaskList();
  int lastDate = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Deadlines'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
            iconSize: 35.0,
            onPressed: () { /* will direct to "Add Task" page */},
          ),
        ]
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          for (var i = 0; i < tasksList.length; i++) ...[
            checkDate(tasksList[i]),
            createTask(tasksList[i]),
            const Divider(height:0),
          ]
        ],)
      ),
    );
  }

  Container checkDate(Task task){
    String date = DateFormat('MMddyyyy').format(task.dueDate);
    if(lastDate != int.parse(date)) {
      lastDate = int.parse(date);
      // ignore: avoid_unnecessary_containers
      return Container(child: ListTile(
        tileColor: Colors.grey.shade300, 
        title: Text("${DateFormat('LLLL').format(task.dueDate)} ${task.dueDate.day}, ${task.dueDate.year}", 
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), 
        ),
      ));
    }
    else { return Container();} // return empty container and move onto next task
  }

  ListTile createTask(Task task) {
    Color priorityColor = Colors.green;
    Color backgroundColor = Colors.white;
    if (task.priority == 1){ priorityColor = Colors.amber; }
    if (task.priority == 2){ priorityColor = Colors.red; }
    if(task.isComplete) {
      backgroundColor = Colors.grey.shade400;
    }

    return ListTile(
      tileColor: backgroundColor,
      title: Text("${task.name} - ${task.courseName}"),
      subtitle: Text("Due: ${DateFormat('LLLL').format(task.dueDate)} ${task.dueDate.day}, ${task.dueDate.year} at ${task.dueDate.hour}:${task.dueDate.minute}"),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.warning, color: priorityColor),
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

List<Task> getTaskList(){
  final task1 = Task("Final Project","CS1000","Finish final project",DateTime(2023,12,10,23,59),3,false);
  final task2 = Task("Review Notes","Math1000","Review notes for exam",DateTime(2023,12,08,11,59),1,false);
  final task3 = Task("Online Quiz","CS1001","Do online quiz",DateTime(2023,12,08,23,59),2,false);
  late List<Task> tasksList = [task1,task2,task3];
  tasksList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return tasksList;
}