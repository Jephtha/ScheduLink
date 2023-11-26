import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'home_page.dart';
/// A stateless widget that acts as an authentication gate.
///
/// It checks the authentication status of the user and decides which
/// screen to show: either th sign-in screen or the home page.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
// Returns a StreamBuilder to listen for authentication state changes.
    return StreamBuilder<User?>(
// Listens to authentication state changes.
      stream: FirebaseAuth.instance.authStateChanges(),
// The builder callback is called whenever the authentication state changes.
      builder: (context, snapshot) {
// If an error occurs while fetching the authentication state, return a
// screen that displays the error.
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(snapshot.error.toString()),
            ),
          );
        }
// If the snapshot does not have data (i.e., user is not authenticated),
// display the sign-in screen.
        if (!snapshot.hasData) {
          return SignInScreen(
// Only the email authentication provider is enabled.
            providers: [
              EmailAuthProvider(), // new
            ],
          );
        } else {
// If the snapshot has data (i.e., user is authenticated),
// display the home page.
          return HomePage(title: 'Course Schedule');
        }
      },
    );
  }
}