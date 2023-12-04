import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'add_deadline_view.dart';
import '../model/course.dart';
import '../controller/schedule_service.dart';

class AddCourseView extends StatefulWidget {
  final List<Course> courses;

  AddCourseView({super.key, required this.courses});

  @override
  State<AddCourseView> createState() => _AddCourseViewState();
}

class _AddCourseViewState extends State<AddCourseView> {
  final ScheduleService scheduleService = ScheduleService();
  List<String> courseNos = [];
  List<Map<String, dynamic>> selectedCourses = [];
  List<Widget> selectedCoursesWidget = [];


  Color assignColor(String condition) {
    final selected = selectedCourses.firstWhere((element) => element['course'] == condition);
    return Color(selected["color"]).withOpacity(1);
  }

  bool updateSelectedCourses(value) {
    if (!selectedCourses.any((element) => element['course'] == value.substring(0, 12))) {
      Course course = widget.courses.firstWhere(
              (course) => "${course.course}-${course.section} ${course.description}".toLowerCase()
                  == value.toLowerCase());

      setState(() {
        selectedCourses.add({
          "course": value.substring(0, 12),
          "color": Colors.grey.value
        });
        selectedCoursesWidget.add(courseWidget(course));
      });

      return true;
    }
    else {
      return false;
    }
  }

  Future<String> addUserToCourseUserList() async {
    String response = '';
    bool failed = false;
    String failedString = 'Already registered for these courses: ';
    for (var element in selectedCourses) {
      response = await scheduleService.addUser2Course(element['course']);
      if (response == "failure") {
        failed = true;
        failedString += element['course'];
      }
    }

    if (failed) {
      return failedString += ". Please remove duplicates";
    }

    return 'passed';
  }

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      courseNos = widget.courses.map((course) => "${course.course}-${course.section} ${course.description}").toList();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!Navigator.canPop(context)) {
        showAlertDialog();
        // Future.delayed(const Duration(seconds: 5), () {
        //   showAlertDialog();
        // });
      }
    });
  }

   void showAlertDialog() {
     showDialog(context: context, builder: (context) {
       bool manuallyClosed = false;
       Future.delayed(Duration(seconds: 3)).then((_) {
         if (!manuallyClosed) {
           Navigator.of(context).pop();
         }
       });
       return AlertDialog(
         title: Text("Welcome"),
         content: Text("Welcome new user! Add your registered courses here to your schedule."),
         actions: [
           TextButton(
             child: Text("OK"),
             onPressed: () {
               manuallyClosed = true;
               Navigator.of(context).pop();
             }
           ),
         ],
       );
     });
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Courses to Calender'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/homepage');
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Courses..',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: courseNos //items
                      .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                    });
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    width: 300,
                  ),
                  dropdownStyleData: const DropdownStyleData(
                    maxHeight: 200,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                  dropdownSearchData: DropdownSearchData(
                    searchController: textEditingController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      height: 50,
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 4,
                        right: 8,
                        left: 8,
                      ),
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        controller: textEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          hintText: 'Search for a course...',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                    },
                  ),
                  //This to clear the search value when you close the menu
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      textEditingController.clear();
                    }
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    bool updated = updateSelectedCourses(selectedValue);
                    if (updated == false) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(Duration(seconds: 3), () {
                              Navigator.of(context).pop(); // Close the dialog
                            });
                            return AlertDialog(
                              title: Text("Warning"),
                              content: Text("Course already selected. Select a different course."),
                              actions: [
                                TextButton(
                                  child: Text("OK"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          }
                      );
                    }
                  },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.green;
                    }
                    return Colors.blue;
                  }),
                ),
                  child: Text('Select'),
              ),
            ],
          ),
          SizedBox(height: 30,),
          Expanded(
            child: ListView.builder(
              itemCount: selectedCoursesWidget.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 10),
              itemBuilder: (context,index)=> selectedCoursesWidget[index],
            ),
          ),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: ()  async {
              scheduleService.addCoursesList2User(selectedCourses);
              String response = await addUserToCourseUserList();

              if (context.mounted) {
                if (response != "passed") {
                  showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(Duration(seconds: 3), () {
                          Navigator.of(context).pop(); // Close the dialog
                        });
                        return AlertDialog(
                          title: Text("Warning"),
                          content: Text(response),
                          actions: [
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                  );
                }
                else {
                  if (!Navigator.canPop(context)) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => AddDeadlineView(),
                      ),
                    );
                  }
                  else {
                    Navigator.of(context).pop();
                  }
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (context) => HomePage()),
                  // );
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.green;
                }
                return Colors.blue;
              }),
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget courseWidget(Course course) {
    return Column(
      key: ValueKey<String>("${course.course}-${course.section}"),
      children: [
        GestureDetector(
          onLongPress: () {
            showDialog(context: context, builder: (context) =>
                AlertDialog(
                    title: const Text('Pick a color!'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: Colors.grey,
                        onColorChanged: (Color changeToColor) {
                          setState(() {
                            final selected = selectedCourses.firstWhere((element) => element['course'] == "${course.course}-${course.section}");
                            selected["color"] = changeToColor.value;
                            int i = selectedCoursesWidget.indexWhere((element) => element.key == ValueKey("${course.course}-${course.section}"));
                            selectedCoursesWidget[i] = courseWidget(course);
                          });
                        },
                      ),
                    ),
                ),
            );
          },
          child: Card(
            key: ValueKey<String>("${course.course}-${course.section}"),
            color: assignColor("${course.course}-${course.section}"),
            elevation: 15.0,
            child: Padding(
              padding: EdgeInsets.only(left: 15, top: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Subject: ', ),
                      Text(course.subject),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Course No: '),
                      Text(course.course),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Section: '),
                      Text(course.section),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Course Description: '),
                      Text(course.description),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Weekly Class Days: '),
                      Text(course.daysOfWeek),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Class Start Time: '),
                      Text("${course.startTime.substring(0, 2)}:${course.startTime.substring(2)}"),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Class End Time: '),
                      Text("${course.endTime.substring(0, 2)}:${course.endTime.substring(2)}"),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Class Location: '),
                      Text(course.location),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedCourses.removeWhere((element) => element['course'] == "${course.course}-${course.section}");
                            selectedCoursesWidget.removeWhere((element) => element.key == ValueKey("${course.course}-${course.section}"));
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                                return Colors.red;
                            }),
                        ),
                        child: Text('Remove', style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 40,)
      ],
    );
  }
}