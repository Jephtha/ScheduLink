import 'package:flutter/material.dart';

import '../../model/user_info.dart';
import '../../controller/schedule_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddCarDialog(),
          );
        }, //_incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}


/// A stateful widget that represents a dialog for adding a new car.
class AddCarDialog extends StatefulWidget {
  @override
  _AddCarDialogState createState() => _AddCarDialogState();
}
class _AddCarDialogState extends State<AddCarDialog> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleService scheduleService = ScheduleService();
  String make = '';
  String model = '';
  int year = DateTime.now().year;

  Future<void> _addCar() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newUser = UserInfo(profileImg: make, contactInfo: model, );
      //await scheduleService.addUser(newUser);
      //await scheduleService.addCourse2User("COMP4768", "Computer Science");
      //await scheduleService.removeCourseFromUser("COMP4768");
      await scheduleService.updateUserInfo(UserInfo(profileImg: 'image', contactInfo: 'contact', userCourses: {"COMP4768": "Computer Science"}));
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Car'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Make'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a make';
                }
                return null;
              },
              onSaved: (value) {
                make = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Model'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a model';
                }
                return null;
              },
              onSaved: (value) {
                model = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a year';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid year';
                }
                return null;
              },
              onSaved: (value) {
                year = int.parse(value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _addCar,
          child: Text('Add'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
