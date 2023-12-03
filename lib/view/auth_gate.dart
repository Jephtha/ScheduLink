import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '/view/homepage.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
          );
        } else {
          return MaterialApp(
              title: 'Class Schedule',
              theme: ThemeData(
                  useMaterial3: true,
                  colorScheme:
                  ColorScheme.fromSeed(seedColor: Colors.lightGreen.shade400)),
              home: const HomePage(),
          );

        }
      },
    );
  }
}