import 'package:easypark_app/ui/pages/home/homepage.dart';
import 'package:easypark_app/ui/pages/login/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:easypark_app/strings.dart' as strings;

import '../strings.dart';

class EasyParkApp extends StatelessWidget {
  const EasyParkApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: loginPage(),
    );
  }
}
