import 'package:easypark_app/ui/home/homepage.dart';
import 'package:flutter/material.dart';
import 'package:easypark_app/strings.dart' as strings;

class EasyParkApp extends StatelessWidget {
  const EasyParkApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyPark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: strings.title),
    );
  }
}
