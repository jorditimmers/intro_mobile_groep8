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
    disabledBackgroundColor: Colors.white24,
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

  void _removeExpiredLocations(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    for (var location in getLocations(snapshot)) {
      if (location.timestamp.toDate().isBefore(DateTime.now())) {
        removeMarkerFromDatabase(location);
        //TODO: IF nextT => addLocation() else removeMarkerFromDB
      }
    }
  }

  StreamBuilder<QuerySnapshot> _markerLayer() => StreamBuilder(
        stream: _locationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator or placeholder
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Show error message
            return Text('Error: ${snapshot.error}');
          } else {
            // Build markers
            List<Marker> markers = _markersList(snapshot);
            return MarkerLayer(markers: markers);
          }
        },
      );

  void writeMarkerToDatabase(LatLng pos, DateTime time) {
    Location l = Location(
        GeoPoint(pos.latitude, pos.longitude),
        globalSessionData.userEmail as String,
        Timestamp.fromDate(time),
        null,
        null);

    FirebaseFirestore.instance
        .collection('Locations')
        .doc(l.geoPoint.longitude.toString() +
            l.geoPoint.latitude.toString() +
            l.timestamp.toString())
        .set(l.toJson());
  }

  void writeNextReservationToLocation(
      Location l, String? nextOwnerEmail, DateTime nextTimestamp) {
    l.nextOwnerEmail = nextOwnerEmail;
    l.nextTimestamp = Timestamp.fromDate(nextTimestamp);
    FirebaseFirestore.instance
        .collection('Locations')
        .doc(l.geoPoint.longitude.toString() +
            l.geoPoint.latitude.toString() +
            l.timestamp.toString())
        .update(l.toJson());
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

  void createNewLocation(LatLng pos) async {
    DateTime? date = await _selectDate(DateTime.now());
    TimeOfDay? time;
    if (date != null) {
      time = await _selectTime();
    }
    if (date != null && time != null) {
      DateTime newDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      writeMarkerToDatabase(pos, newDate);
    }
  }

  void updateLocation(Location l, DateTime start) async {
    DateTime? date = await _selectDate(start);
    TimeOfDay? time;
    if (date != null) {
      time = await _selectTime();
    }
    if (date != null && time != null) {
      DateTime newDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (!newDate.isBefore(start)) {
        writeNextReservationToLocation(l, globalSessionData.userEmail, newDate);
      }
    } else {
      return;
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
                            createNewLocation(latlng);
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
    Column reserved =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('This spot is reserved until ${location.timestamp.toDate()}'),
          Text('Next reservation: ${location.nextTimestamp?.toDate()}')
        ],
      ),
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
          child: Text('Cancel current reservation')),
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
          child: Text('Cancel next reservation'))
    ]);
    Column notReserved =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('This spot is reserved until ${location.timestamp.toDate()}'),
          Text('Next reservation: ${location.nextTimestamp?.toDate()}')
        ],
      ),
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
            if (location.nextOwnerEmail == null) {
              updateLocation(location, location.timestamp.toDate());
            } else {
              null;
            }
          },
          child: Text('Extend Reservation')),
    ]);
    if (location.nextOwnerEmail == null) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: notReserved));
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: reserved));
    }
  }

  void showOthersMarkerMenu(Location location) {
    Column notReserved =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Reserved until ${location.timestamp.toDate()}'),
          Text('Next reservation: ${location.nextTimestamp?.toDate()}')
        ],
      ),
      ElevatedButton(
          style: blueRounded,
          onPressed: () {
            if (location.nextOwnerEmail == null) {
              updateLocation(location, location.timestamp.toDate());
            } else {
              null;
            }
          },
          child: const Text('Reserve spot'))
    ]);

    Column reserved = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Reserved until ${location.timestamp.toDate()}'),
        Text('Next reservation: ${location.nextTimestamp?.toDate()}')
      ],
    );
    if (location.nextOwnerEmail != null) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: reserved,
              ));
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: notReserved,
              ));
    }
  }

  List<Marker> _markersList(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    List<Marker> markers = [];
    List<Location> locations = [];
    locations = getLocations(snapshot);
    List<LatLng> geoPoints = markers.map((e) {
      return e.point;
    }).toList();
    _removeExpiredLocations(snapshot);
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
                  color: Colors.purple,
                ),
              );
            }));
      } else if (location.nextOwnerEmail == null &&
          location.timestamp
              .toDate()
              .isBefore(DateTime.now().add(const Duration(minutes: 15)))) {
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
                  color: Colors.yellow,
                ),
              );
            }));
      } else if (location.nextOwnerEmail == null) {
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
                  color: Colors.red,
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
