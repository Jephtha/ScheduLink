import 'package:flutter/material.dart';
import 'package:choice/choice.dart';
import 'package:bottom_picker/bottom_picker.dart';

import '../model/task.dart';
import '../controller/schedule_service.dart';
import 'package:schedulink/controller/notifications_service.dart';
import 'package:schedulink/model/notification.dart';

class AddDeadlineView extends StatefulWidget {
  const AddDeadlineView({super.key});

  @override
  State<AddDeadlineView> createState() => _AddDeadlineViewState();
}

class _AddDeadlineViewState extends State<AddDeadlineView> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleService scheduleService = ScheduleService();
  DateTime selectedDate = DateTime.now();
  TextEditingController dateTimeController = TextEditingController();

  /*Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }*/

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDateTime != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );

      if (pickedTime != null) {
        pickedDateTime = DateTime(
          pickedDateTime.year,
          pickedDateTime.month,
          pickedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          selectedDate = pickedDateTime!;
          dateTimeController.text = selectedDate.toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a future time'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a future date'),
        ),
      );
    }
  }

  Future<void> showDateTimePicker(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Reminder'),
          content: Column(
            children: [
              /*ListTile(
                title: Text('Date: ${selectedDate.toLocal()}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () {
                  if (selectedDate.isAfter(DateTime.now())) {
                    _selectDate(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Notification scheduled for $selectedDate'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a future time'),
                      ),
                    );
                  }
                },
              ),*/
              TextFormField(
                controller: dateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  labelText: 'Select Date and Time',
                ),
                onTap: () => _selectDateTime(context),
              ),
              /*ListTile(
                title: Text('Time: ${selectedDate.toLocal().toLocal()}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),*/
            ],
          ),
          actions: <Widget>[
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    var id = '${dueDate.year}${dueDate.month}${dueDate.day}';
                    NotificationService().scheduleNotification(NotificationItem(
                        id: id,
                        title: name,
                        description: description,
                        deadlineDate: selectedDate));
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String name = '';
  String course = '';
  DateTime dueDate = DateTime(2023, 1, 15);
  String description = '';

  List<String> priorityTags = ['low', 'medium', 'high'];
  List<String> statusTags = ['incomplete', 'in progress', 'complete'];

  String? selectedPriorityValue = 'low';
  String? selectedStatusValue = 'incomplete';

  void setSelectedPriorityValue(String? value) {
    setState(() => selectedPriorityValue = value);
  }

  void setSelectedStatusValue(String? value) {
    setState(() => selectedStatusValue = value);
  }

  Future<void> _addDeadline() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newDeadline = DeadlineTask(
          name: name,
          course: course,
          dueDate: dueDate,
          description: description,
          priority: selectedPriorityValue!,
          status: selectedStatusValue!);

      await scheduleService.addDeadline(newDeadline);

      //Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'Add Deadline',
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Name: ', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    height: 70,
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() => name = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Course: ', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    height: 70,
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Course'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 8) {
                          return 'Please enter a Course in the ABCD1234 format';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() => course = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Due Date: ', style: TextStyle(fontSize: 16)),
                  // date time picker widget
                  SizedBox(
                    width: 70,
                    height: 30,
                    child: ElevatedButton(
                        onPressed: () {
                          BottomPicker.dateTime(
                            title: 'Set the event exact time and date',
                            titleStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            onSubmit: (date) {
                              //dueDate = date;
                              setState(() {
                                dueDate = date;
                              });
                              print(date);
                            },
                            onClose: () {
                              print('Picker closed');
                            },
                            iconColor: Colors.black,
                            minDateTime: DateTime(2024, 1, 1),
                            maxDateTime: DateTime(2024, 4, 30),
                            initialDateTime: DateTime(2024, 1, 15),
                            gradientColors: [
                              Color(0xfffdcbf1),
                              Color(0xffe6dee9)
                            ],
                          ).show(context);
                        },
                        child: Text('Date') //const Icon(Icons.date_range),'
                        ),
                  ),
                  SizedBox(width: 10),
                  Text(dueDate.toString(), style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Description: ', style: TextStyle(fontSize: 16)),
                  SizedBox(
                    height: 70,
                    width: 250,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      onSaved: (value) {
                        setState(() => description = value!);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Priority: ', style: TextStyle(fontSize: 16)),
                  InlineChoice<String>.single(
                    clearable: true,
                    value: selectedPriorityValue,
                    onChanged: setSelectedPriorityValue,
                    itemCount: priorityTags.length,
                    itemBuilder: (state, i) {
                      return ChoiceChip(
                        selected: state.selected(priorityTags[i]),
                        selectedColor: Colors.blue,
                        onSelected: state.onSelected(priorityTags[i]),
                        label: Text(priorityTags[i]),
                      );
                    },
                    listBuilder: ChoiceList.createScrollable(
                      spacing: 10,
                      runSpacing: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Status: ', style: TextStyle(fontSize: 16)),
                  InlineChoice<String>.single(
                    clearable: true,
                    value: selectedStatusValue,
                    onChanged: setSelectedStatusValue,
                    itemCount: statusTags.length,
                    itemBuilder: (state, i) {
                      return ChoiceChip(
                        selected: state.selected(statusTags[i]),
                        selectedColor: Colors.blue,
                        onSelected: state.onSelected(statusTags[i]),
                        label: Text(statusTags[i]),
                      );
                    },
                    listBuilder: ChoiceList.createScrollable(
                      spacing: 10,
                      runSpacing: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _addDeadline;
                    await showDateTimePicker(context);
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
