import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'view/auth_gate.dart';

// background handler
Future backgroundHandler(RemoteMessage msg) async {}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // load course data before running App.
  // getCourses().then((value) {
  //   runApp(const MainApp());
  // });

  runApp(const MainApp());
}

// Future<List<Course>> getCourses() async{
//   ScheduleService scheduleService = ScheduleService();
//   return await scheduleService.fetchCourses();
// }

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthGate(),
    );
  }
}
