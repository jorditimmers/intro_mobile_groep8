import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark_app/global/global.dart';
import 'package:easypark_app/model/car.dart';
import 'package:easypark_app/ui/pages/settings/addcar.dart';
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
  late Future<List<Car>> _data;

  @override
  void initState() {
    // cars.add(Car('Brand', 'Model', 'Color', 'Plate', 'OwnerEmail'));
    _data = getCars(globalSessionData.userEmail as String);
    // futureCars.then((value) => {
    //       print(value),
    //       for (Car c in value) {cars.add(c)}
    //     });
    super.initState();
  }

  Future<List<Car>> getCars(String mail) async {
    final doc = await FirebaseFirestore.instance
        .collection('Cars')
        .where('OwnerEmail', isEqualTo: mail)
        .get();

    List<Car> _Cars = doc.docs.map((d) => Car.fromJson(d.data())).toList();
    return _Cars;
  }

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
        ),
        body: ListView(
          children: <Widget>[
            SettingsList(
              shrinkWrap: true,
              sections: [
                SettingsSection(
                  title: Text('Add Car'),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      leading: Icon(Icons.add),
                      title: Text('Add Car'),
                      value:
                          Text('Add a car that you own to your list of cars'),
                      onPressed: (context) => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => addCar()),
                        ) //OPEN MENU HERE
                      },
                    ),
                  ],
                ),
              ],
            ),
            FutureBuilder(
                future: _data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SettingsList(
                      shrinkWrap: true,
                      sections: [
                        SettingsSection(
                          title: Text('Your Cars'),
                          tiles: <SettingsTile>[
                            for (Car car in snapshot.data!)
                              SettingsTile(
                                title: Text(car.Brand + " " + car.Model),
                                value: Text(car.Color + " | " + car.Plate),
                              ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Text('LOADING');
                  }
                })
          ],
        ));
  }
}
