import 'package:flutter/material.dart';
import 'package:schedulink/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainApp(),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Class Schedule',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.lightGreen.shade400)),
      home: const HomePage());
}