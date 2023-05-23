import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark_app/global/global.dart';
import 'package:easypark_app/model/car.dart';
import 'package:easypark_app/ui/pages/settings/addcar.dart';
import 'package:easypark_app/ui/pages/settings/carsettings.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:easypark_app/global/global.dart';

class DeleteCar extends StatefulWidget {
  const DeleteCar({super.key});

  @override
  State<DeleteCar> createState() => _DeleteCarState();
}

class _DeleteCarState extends State<DeleteCar> {
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

  Future<void> deleteCar(Car car) async {
    var ref;
    final col = await FirebaseFirestore.instance
        .collection('Cars')
        .where('OwnerEmail', isEqualTo: globalSessionData.userEmail)
        .where('Brand', isEqualTo: car.Brand)
        .where('Color', isEqualTo: car.Color)
        .where('Model', isEqualTo: car.Model)
        .limit(1)
        .get()
        .then((snapshot) => {
              ref = snapshot.docs[0].reference,
              snapshot.docs[0].reference.delete()
            });

    final col2 = await FirebaseFirestore.instance
        .collection('Locations')
        .where('Car', isEqualTo: ref)
        .get()
        .then((snapshot) => {
              for (var s in snapshot.docs) {s.reference.delete()}
            });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => CarSettings()));
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
            FutureBuilder(
                future: _data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SettingsList(
                      shrinkWrap: true,
                      sections: [
                        SettingsSection(
                          title: Text('SelectToDelete'),
                          tiles: <SettingsTile>[
                            for (Car car in snapshot.data!)
                              SettingsTile(
                                title: Text(car.Brand + " " + car.Model),
                                value: Text(car.Color),
                                onPressed: (context) => {deleteCar(car)},
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
