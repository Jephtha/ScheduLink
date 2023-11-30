import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:schedulink/view/schedule.dart';

import 'homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  final AuthAction state = AuthAction.signIn;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          SignOutButton();
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        if (snapshot.hasData) {
          return MaterialApp(
            title: 'Class Schedule',
            theme: ThemeData(
                useMaterial3: true,
                colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.lightGreen.shade400)),
            home: const HomePage(),
          );
        }
        else {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
            actions: [
              AuthStateChangeAction<UserCreated>((context, state) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Schedule()
                  ), (route) => false
                );
              }),
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => HomePage()
                  ), (route) => false
                );
              }),
            ],
          );
        }
      },
    );
  }
}