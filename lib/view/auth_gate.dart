import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'homepage.dart';
import 'profile.dart';
import 'add_course_view.dart';
import '../model/course.dart';
import '../controller/schedule_service.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  final AuthAction state = AuthAction.signIn;

  Future<List<Course>> getCourses() async {
    ScheduleService scheduleService = ScheduleService();
    return await scheduleService.fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Authentication Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute:
        FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/homepage',
        routes: {
          '/sign-in': (context) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
              ],
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  Navigator.pushReplacementNamed(context, '/homepage');
                }),
                AuthStateChangeAction<UserCreated>((context, state) {
                  getCourses().then((value) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => AddCourseView(courses: value)
                      ), (route) => false
                    );
                  });
                }),
              ],
            );
          },
          // '/profile': (context) {
          //   return ProfileScreen(
          //     actions: [
          //       SignedOutAction((context) {
          //         Navigator.pushReplacementNamed(context, '/sign-in');
          //       }),
          //     ],
          //   );
          // },
          '/profile': (context) {
            return Profile();
          },
          '/homepage': (context) {
            return HomePage();
          },

        });
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           SignOutButton();
//           return Scaffold(
//             body: Center(
//               child: Text(snapshot.error.toString()),
//             ),
//           );
//         }
//         if (snapshot.hasData) {
//           return MaterialApp(
//             title: 'Class Schedule',
//             theme: ThemeData(
//                 useMaterial3: true,
//                 colorScheme:
//                 ColorScheme.fromSeed(seedColor: Colors.lightGreen.shade400)),
//             home: const HomePage(),
//           );
//         }
//         else {
//           return SignInScreen(
//             providers: [
//               EmailAuthProvider(),
//             ],
//             actions: [
//               AuthStateChangeAction<UserCreated>((context, state) {
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                       builder: (context) => Schedule()
//                   ), (route) => false
//                 );
//               }),
//               AuthStateChangeAction<SignedIn>((context, state) {
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                       builder: (context) => HomePage()
//                   ), (route) => false
//                 );
//               }),
//             ],
//           );
//         }
//       },
//     );
//   }
// }

