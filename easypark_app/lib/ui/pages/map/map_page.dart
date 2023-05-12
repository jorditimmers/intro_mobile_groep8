import 'dart:html';

import 'package:easypark_app/extensions/geopoint_extensions.dart';
import 'package:easypark_app/global/global.dart';
import 'package:easypark_app/model/location.dart';
import 'package:easypark_app/ui/elements/headerbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Stream<QuerySnapshot> _locationsStream = Stream.empty();
  @override
  initState() {
    super.initState();
    _locationsStream =
        FirebaseFirestore.instance.collection('Locations').snapshots();
  }

  ButtonStyle blueRounded = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blue,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );

  ButtonStyle grayRounded = ElevatedButton.styleFrom(
    foregroundColor: Colors.white60,
    backgroundColor: Colors.black45,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );

  List<Location> getLocations(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return snapshot.data!.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Location.fromJson(data);
    }).toList();
    // return snapshot.data!.docs
    //     .map((doc) {
    //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //       return Location.fromJson(data);
    //     })
    //     .where(
    //         (location) => location.timestamp.toDate().isAfter(DateTime.now()))
    //     .toList();
  }

  StreamBuilder<QuerySnapshot> _markerLayer() => StreamBuilder(
      stream: _locationsStream,
      builder: (context, snapshot) {
        List<Marker> markers = _markersList(snapshot);
        return MarkerLayer(markers: markers);
      });

  void onMapReady() {}

  void writeMarkerToDatabase(LatLng pos, DateTime time, bool isReserved) {
    Location l = Location(
        GeoPoint(pos.latitude, pos.longitude),
        globalSessionData.userEmail as String,
        Timestamp.fromDate(time),
        isReserved);

    FirebaseFirestore.instance
        .collection('Locations')
        .doc(l.geoPoint.longitude.toString() +
            l.geoPoint.latitude.toString() +
            l.timestamp.toString())
        .set(l.toJson());
  }

  void removeMarkerFromDatabase(Location l) {
    FirebaseFirestore.instance
        .collection('Locations')
        .doc(l.geoPoint.longitude.toString() +
            l.geoPoint.latitude.toString() +
            l.timestamp.toString())
        .delete();
  }

  Future<DateTime?> _selectDate(DateTime start) async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: start,
        firstDate: start,
        lastDate: DateTime.now().add(Duration(days: 1)));
    return date;
  }

  Widget _buildConfirmDeparture(BuildContext context, Location location) {
    return AlertDialog(
      title: const Text('Confirm Departure'),
      content: const Text('Are you sure you want to leave your spot?'),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('close')),
        ElevatedButton(
            onPressed: () {
              removeMarkerFromDatabase(location);
              Navigator.of(context).pop();
            },
            child: Text('Confirm departure'))
      ],
    );
  }

  Future<TimeOfDay?> _selectTime() async {
    TimeOfDay? newTime;
    newTime = await showTimePicker(
      confirmText: 'Confirm your reservation',
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    return newTime;
  }

  void _selectDateAndTime(LatLng pos, DateTime start, isReserved) async {
    DateTime? date = await _selectDate(start);
    TimeOfDay? time;
    if (date != null) {
      time = await _selectTime();
    }
    if (date != null && time != null) {
      DateTime newDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      writeMarkerToDatabase(pos, newDate, isReserved);
    }
  }

  void reserveMenu(LatLng latlng, DateTime startTime) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        useSafeArea: true,
        context: context,
        builder: (context) {
          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      child: ElevatedButton(
                          style: blueRounded,
                          child: const Text('Reserve'),
                          onPressed: () {
                            Navigator.pop(context);
                            _selectDateAndTime(latlng, startTime, false);
                          }),
                    ),
                    SizedBox(
                      child: ElevatedButton(
                          style: grayRounded,
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    )
                  ],
                ),
              ));
        }).whenComplete(() => {});
  }

  void showOwnMarkerMenu(Location location) {
    showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Reserved until ${location.timestamp.toDate()}'),
                    ElevatedButton(
                        style: blueRounded,
                        onPressed: () {
                          //TODO: Confirmation pop up
                          showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  _buildConfirmDeparture(context, location));
                          Navigator.of(context).pop(context);
                        },
                        child: Text('Indicate Departure')),
                    ElevatedButton(
                        style: blueRounded,
                        onPressed: () {
                          if (!location.isReserved) {
                            _selectDateAndTime(location.geoPoint.toLatLng(),
                                location.timestamp.toDate(), true);
                          } else {
                            null;
                          }
                        },
                        child: Text('Extend Reservation')),
                  ]),
            ));
  }

  void showOthersMarkerMenu(Location location) {
    showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Reserved until ${location.timestamp.toDate()}'),
                    ElevatedButton(
                        style: blueRounded,
                        onPressed: () {
                          if (!location.isReserved) {
                            _selectDateAndTime(location.geoPoint.toLatLng(),
                                location.timestamp.toDate(), true);
                          } else {
                            null;
                          }
                        },
                        child: const Text('Reserve spot'))
                  ]),
            ));
  }

  List<Marker> _markersList(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    List<Marker> markers = [];
    List<Location> locations = getLocations(snapshot);
    for (var location in locations) {
      if (location.timestamp
          .toDate()
          .isBefore(DateTime.now().add(const Duration(minutes: 30)))) {
        //TODO: change marker color om time
      }
      if (location.ownerEmail == globalSessionData.userEmail) {
        markers.add(Marker(
            point: location.geoPoint.toLatLng(),
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  showOwnMarkerMenu(location);
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 42,
                  color: Colors.green,
                ),
              );
            }));
      } else {
        markers.add(Marker(
            point: location.geoPoint.toLatLng(),
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  showOthersMarkerMenu(location);
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 42,
                  color: Colors.blue,
                ),
              );
            }));
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerBar(context),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          onMapReady: () {},
          minZoom: 18,
          maxZoom: 18,
          maxBounds: LatLngBounds(
              LatLng(51.22978, 4.41376), LatLng(51.22765, 4.41789)),
          onTap: (tp, latlng) {
            reserveMenu(latlng, DateTime.now());
          },
          center: LatLng(51.22857, 4.41646),
          zoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'edu.ap.mobilegroep8',
          ),
          _markerLayer(),
        ],
      ),
    );
  }
}
