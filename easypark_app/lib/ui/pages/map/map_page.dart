import 'dart:html';

import 'package:easypark_app/extensions/geopoint_extensions.dart';
import 'package:easypark_app/global/global.dart';
import 'package:easypark_app/model/location.dart';
import 'package:easypark_app/services/LocationService.dart';
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
  late final LocationService _service;
  late Stream<QuerySnapshot<Object?>>? _locationsStream;
  @override
  initState() {
    super.initState();
    _service = LocationService();
    _locationsStream = _service.getLocationsStream();
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

  void _removeExpiredLocations(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    for (var doc in snapshot.data!.docs) {
      Location l = Location.fromJson(doc.data() as Map<String, dynamic>);
      if (l.timestamp.toDate().isBefore(DateTime.now())) {
        if (l.nextTimestamp == null) {
          _service.deleteLocation(doc.id);
        } else {
          _service.deleteLocation(doc.id);
          Location newLocation = updateLocationToNextReservation(l);
          _service.addLocation(newLocation);
        }
      }
    }
  }

  StreamBuilder<QuerySnapshot<Object?>> _markerLayer() => StreamBuilder(
        stream: _locationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator or placeholder
            return const CircularProgressIndicator();
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

  Location updateLocationToNextReservation(Location l) {
    if (l.nextTimestamp != null) {
      return Location(l.geoPoint, l.nextOwnerEmail as String,
          l.nextTimestamp as Timestamp, null, null);
    } else {
      return l;
    }
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
              //TODO: remove marker
              //removeMarkerFromDatabase(location);
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

  Location positionToLocation(LatLng pos, DateTime time) {
    return Location(
        GeoPoint(pos.latitude, pos.longitude),
        globalSessionData.userEmail as String,
        Timestamp.fromDate(time),
        null,
        null);
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
      _service.addLocation(positionToLocation(pos, newDate));
    }
  }

  void updateLocation(DocumentSnapshot doc, DateTime start) async {
    Location l = docToLocation(doc);
    DateTime? date = await _selectDate(start);
    TimeOfDay? time;
    if (date != null) {
      time = await _selectTime();
    }
    if (date != null && time != null) {
      DateTime newDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (!newDate.isBefore(start)) {
        _service.deleteLocation(doc.id);
        l.nextOwnerEmail = globalSessionData.userEmail;
        l.nextTimestamp = Timestamp.fromDate(newDate);
        _service.addLocation(l);
      }
    } else {
      return;
    }
  }

  Location docToLocation(DocumentSnapshot doc) {
    return Location.fromJson(doc.data() as Map<String, dynamic>);
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

  void _indicateDepartue() {}

  void showOwnMarkerMenu(DocumentSnapshot doc) {
    Location location = docToLocation(doc);
    Column firstReserved =
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
            _service.deleteLocation(doc.id);
            Location newLocation = updateLocationToNextReservation(location);
            _service.addLocation(newLocation);
            Navigator.of(context).pop(context);
          },
          child: Text('Cancel reservation')),
    ]);
    Column bothReserved =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('This spot is reserved until ${location.timestamp.toDate()}'),
          Text(
              'Reservation extended until: ${location.nextTimestamp?.toDate()}')
        ],
      ),
      ElevatedButton(
          style: blueRounded,
          onPressed: () {
            _service.deleteLocation(doc.id);
            Location newLocation = updateLocationToNextReservation(location);
            _service.addLocation(newLocation);
            Navigator.of(context).pop(context);
          },
          child: Text('Cancel current reservation')),
      ElevatedButton(
          style: blueRounded,
          onPressed: () {
            _service.deleteLocation(doc.id);
            Location newLocation = positionToLocation(
                location.geoPoint.toLatLng(), location.timestamp.toDate());
            _service.addLocation(newLocation);
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
            if (location.nextOwnerEmail == null) {
              _service.deleteLocation(doc.id);
            } else {
              updateLocationToNextReservation(location);
            }
            Navigator.of(context).pop(context);
          },
          child: Text('Indicate Departure')),
      ElevatedButton(
          style: blueRounded,
          onPressed: () {
            if (location.nextOwnerEmail == null) {
              Navigator.of(context).pop();
              updateLocation(doc, location.timestamp.toDate());
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
    } else if (location.nextOwnerEmail == globalSessionData.userEmail) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: bothReserved));
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: firstReserved));
    }
  }

  void showOthersMarkerMenu(DocumentSnapshot doc) {
    Location location = docToLocation(doc);
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
              Navigator.of(context).pop();
              updateLocation(doc, location.timestamp.toDate());
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

    Column userReserved = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Reserved until ${location.timestamp.toDate()}'),
        Text('Your reservation: ${location.nextTimestamp?.toDate()}'),
        ElevatedButton(
            style: blueRounded,
            onPressed: () {
              _service.deleteLocation(doc.id);
              Location newLocation = location;
              newLocation.nextOwnerEmail = null;
              newLocation.nextTimestamp = null;
              _service.addLocation(newLocation);
              Navigator.of(context).pop(context);
            },
            child: const Text('Cancel reservation'))
      ],
    );
    if (location.nextOwnerEmail == null) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: notReserved,
              ));
    } else if (location.nextOwnerEmail == globalSessionData.userEmail) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: userReserved,
              ));
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: reserved,
              ));
    }
  }

  List<Marker> _markersList(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Marker> markers = [];
    _removeExpiredLocations(snapshot);
    for (var doc in snapshot.data!.docs) {
      Location location = docToLocation(doc);
      if (location.ownerEmail == globalSessionData.userEmail) {
        markers.add(Marker(
            point: location.geoPoint.toLatLng(),
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  showOwnMarkerMenu(doc);
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
                  showOthersMarkerMenu(doc);
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 42,
                  color: Colors.green,
                ),
              );
            }));
      } else if (location.nextOwnerEmail == null) {
        markers.add(Marker(
            point: location.geoPoint.toLatLng(),
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  showOthersMarkerMenu(doc);
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 42,
                  color: Colors.yellow,
                ),
              );
            }));
      } else {
        markers.add(Marker(
            point: location.geoPoint.toLatLng(),
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  showOthersMarkerMenu(doc);
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
