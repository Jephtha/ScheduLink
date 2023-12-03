import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:schedulink/controller/notifications_service.dart';
//import 'package:schedulink/utils/dialog.dart';
import 'package:schedulink/view/add_deadline_view.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  //bool light = true;
  /*User? user = FirebaseAuth.instance.currentUser;
  SignIn loggedInUser = SignIn();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("AccountDetails")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = SignIn.fromJson(value.data()!);
    });
  }*/
  Future pendingNotifications =
      NotificationService().retrievePendingNotifications();
  List listNotifications = [];

  _getList() async {
    listNotifications = await pendingNotifications;
  }

  /*Stream<ActiveNotification> readNotifications() =>
      NotificationService().retrieveActiveNotifications();*/

  @override
  Widget build(BuildContext context) {
    _getList();
    Widget buildNotification(PendingNotificationRequest notification) {
      return Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          ListTile(
            tileColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            leading: Icon(Icons.alarm_on),
            title: RichText(
              text: TextSpan(
                text: '${notification.title} - Due: ${notification.id}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            subtitle: RichText(
              text: TextSpan(
                text: notification.body,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              onPressed: () {
                NotificationService().cancel(notification.id);
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      //backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Notifications",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddDeadlineView()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 40,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4.0,
                          offset: Offset(2.0, 2.0),
                        ),
                        Shadow(
                          color: Colors.grey,
                          blurRadius: 4.0,
                          offset: Offset(-2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 100,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 800,
                child: ListView.builder(
                  itemCount: listNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = listNotifications[index];
                    if (notification != null) {
                      return Column(
                        children: [
                          buildNotification(notification),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          const Center(child: CircularProgressIndicator()),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
