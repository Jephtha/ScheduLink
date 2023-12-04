import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:provider/provider.dart';
import 'package:schedulink/controller/theme_services.dart';

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
          SignOutButton();
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
          );
        } else {
          return MaterialApp(
            theme: Provider.of<ThemeProvider>(context).isDarkMode
                ? ThemeData.dark()
                : ThemeData.light(),
            title: 'Class Schedule',
            home: const HomePage(),
          );
        }
      },
    );
  }
}
