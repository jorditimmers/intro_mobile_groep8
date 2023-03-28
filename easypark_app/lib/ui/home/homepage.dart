import 'package:easypark_app/strings.dart';
import 'package:easypark_app/ui/map/map_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildTitle(),
            ElevatedButton(
              style: style,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MapPage(),
                  ),
                );
              },
              child: const Text('Map'),
            ), // Map Button
            const SizedBox(height: 30),
            ElevatedButton(
              style: style,
              onPressed: () {},
              child: const Text('Indicate Departure'),
            ), //Departure button
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() => Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
      );
}
