import 'package:flutter/material.dart';
import 'package:schedulink/model/course.dart';

import '../controller/schedule_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScheduleService scheduleService = ScheduleService();
  late Map<String, dynamic> courses;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<List<Course>> getCourses() async{
    return await scheduleService.fetchCourses();
    // setState(() {
    //   courses = response;
    // });
  }

  @override
  void initState() {
    super.initState();
    //getCourses();

    // getCourses().then((response) {
    //   setState(() {
    //     courses = response;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,//() => scheduleService.addUser2Course("PSYC1000", "byvujhuj647856"),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
