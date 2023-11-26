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
// Key to identify and validate the form.
  final _formKey = GlobalKey<FormState>();
// Instance of CarService to interact with Firestore for CRUD operations on cars.
  final ScheduleService scheduleService = ScheduleService();
// Variables to hold the values from the form.
  String make = '';
  String model = '';
  int year = DateTime.now().year; // Default the year to the current year.
  /// Asynchronously adds the car to Firestore.
  Future<void> _addCar() async {
// Validates the form's current state.
    if (_formKey.currentState!.validate()) {
// Saves the form's current state.
      _formKey.currentState!.save();
// Creates a new Car instance with the form data.
      final newUser = UserInfo(profileImg: make, contactInfo: model, );
// Uses the CarService instance to add the new car to Firestore.
      await scheduleService.addUser(newUser);
// Closes the dialog.
      Navigator.of(context).pop();
    }
  }
  @override
  Widget build(BuildContext context) {
// Returns an AlertDialog widget to collect car details from the user.
    return AlertDialog(
      title: Text('Add Car'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
// Text form field to collect the car's make.
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
// Text form field to collect the car's model.
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
// Text form field to collect the car's year.
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
// Elevated button to trigger the _addCar method when clicked.
        ElevatedButton(
          onPressed: _addCar,
          child: Text('Add'),
        ),
// Text button to close the dialog without adding a car.
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
