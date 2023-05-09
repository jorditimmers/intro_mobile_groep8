import 'package:easypark_app/strings.dart';
import 'package:easypark_app/ui/pages/map/map_page.dart';
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
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return Scaffold(
        appBar: headerBar(context),
        body: Center(
          child: Column(children: [
            SizedBox(
              height: 10,
            ),
            GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color.fromARGB(64, 0, 0, 0),
                          image: DecorationImage(
                              image: AssetImage("assets/images/map.png"),
                              fit: BoxFit.cover), // button text
                        )),
                    Text('MAP',
                        style: const TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(10.0, 10.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              Shadow(
                                offset: Offset(10.0, 10.0),
                                blurRadius: 8.0,
                                color: Color.fromARGB(124, 0, 0, 0),
                              ),
                            ],
                            fontFamily: 'SF_Pro',
                            fontSize: 80,
                            color: Colors.white))
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                }),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.90,
                        height: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color.fromARGB(64, 0, 0, 0),
                          image: DecorationImage(
                              image: AssetImage("assets/images/depart.jpeg"),
                              fit: BoxFit.cover), // button text
                        )),
                    Text('DEPARTURE',
                        style: const TextStyle(
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(10.0, 10.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                              Shadow(
                                offset: Offset(10.0, 10.0),
                                blurRadius: 8.0,
                                color: Color.fromARGB(124, 0, 0, 0),
                              ),
                            ],
                            fontFamily: 'SF_Pro',
                            fontSize: 80,
                            color: Colors.white))
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                }),
          ]),
        ));
  }
}
