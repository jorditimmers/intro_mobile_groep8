import 'package:easypark_app/strings.dart';
import 'package:flutter/material.dart';

import '../../elements/headerbar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerBar(context),
    );
  }
}
