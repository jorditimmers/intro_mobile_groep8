import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:settings_ui/settings_ui.dart';

class CarSettings extends StatefulWidget {
  const CarSettings({super.key});

  @override
  State<CarSettings> createState() => _CarSettingsState();
}

class _CarSettingsState extends State<CarSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      backgroundColor: Colors.blue,
      title: const Text(
        'Car Settings',
        style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF_Pro'),
      ),
      leading: IconButton(
        color: Colors.white,
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ));
  }
}
