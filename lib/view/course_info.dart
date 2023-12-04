import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';

import '../model/course.dart';
import '../model/user_info.dart';
import '../controller/schedule_service.dart';

class CourseInfo extends StatefulWidget {
  
  final Course course;
  const CourseInfo({super.key,required this.course});

  @override
  State<CourseInfo> createState() => _CourseInfoState();
}

class _CourseInfoState extends State<CourseInfo> {
  ScheduleService scheduleService = ScheduleService();
  final currentUser = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.course.course),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: getCourseInfo(widget.course),
      ),
    );
  }

  Future<UserInfo> getUserInfo(String userId) async {
    UserInfo userInfo = await scheduleService.getUserInfoFromId(userId);

    return userInfo;
  }

  Widget getCourseInfo(Course course) {

    DateTime start = DateTime(1,1,1,int.parse(course.startTime.toString().substring(0,2)),int.parse(course.startTime.toString().substring(2)));
    DateTime end = DateTime(1,1,1,int.parse(course.endTime.toString().substring(0,2)),int.parse(course.endTime.toString().substring(2)));

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width,
      ),
      width: MediaQuery.sizeOf(context).width,
      color: Colors.blueGrey,
      child: Card(
        color: Colors.white38,
        shadowColor: Colors.grey,
        //margin: EdgeInsets.only(top: 100),
        elevation: 15.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            RichText( text: TextSpan(
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(text: "Course: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${course.course}-${course.section}'),
                TextSpan(text: "\nName: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: course.description),
                TextSpan(text: "\nCRN: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: course.crn),
                TextSpan(text: "\nClasses: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: "${course.daysOfWeek}, ${DateFormat.jm().format(start)}-${DateFormat.jm().format(end)}"),
                TextSpan(text: "\nLocation: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: course.location),
                TextSpan(text: "\nUsers registered for this course: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            ])),

            SizedBox(height: 10,),

            FutureBuilder(
              future: scheduleService.getCourseUserList("${course.course}-${course.section}"),
              builder: (context, snapshot) {
                List<String>? users = snapshot.data;
                if (snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      for(var i=0;i<users!.length;i++)
                        user(users[i]),
                    ])
                  );
                }
                else {
                  return Container(child: null);
                }
              }),
            ]
          )
        ),
      ),
    );
  }

  Widget user(String userId) {
    GlobalKey key = GlobalKey();

    return FutureBuilder(
        future: scheduleService.getUserInfoFromId(userId),
        builder: (context, snapshot) {
          UserInfo? user = snapshot.data;
          if (snapshot.hasData) {
            return Column(
              children: [
                ElevatedButton(
                  key: key,
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      shadowColor: MaterialStateProperty.all<Color>(Colors.grey),
                      elevation: MaterialStateProperty.resolveWith<double>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) return 10;
                          return 5; // default elevation
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      animationDuration: Duration(milliseconds: 200)
                  ),
                  onPressed: () => userPopUp(user, key),
                  child: Text(
                    user!.name,
                  ),
                ),
                SizedBox(height: 10,),
              ],
            );
          } else {
            return SizedBox();
          }
        });
  }

  Widget userPopUp(UserInfo user, GlobalKey key) {
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    double dy = position.dy;
    double dx = position.dx;

    showPopupCard<String>(
      context: context,
      builder: (context) {
        return PopupCard(
          elevation: 10,
          color: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: PopupCardDetails(name: user.name, contact: user.contactInfo, imgPath: user.profileImg),
        );
      },
      offset: Offset(dx+100, dy-100), //const Offset(-8, 60),
      alignment: Alignment.topLeft,
      useSafeArea: true,
    );

    return SizedBox();
  }

}


class PopupCardDetails extends StatelessWidget {
  final String name;
  final String contact;
  final String imgPath;

  const PopupCardDetails({super.key, required this.name, required this.contact, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            getImgAvatar(context),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 2.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                contact,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget getImgAvatar(BuildContext context) {
    if (imgPath == '') {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: Text(
          name[0],
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }
    else {
      return CircleAvatar(
        backgroundImage: NetworkImage(imgPath),
        radius: 50,
      );
    }
  }
}