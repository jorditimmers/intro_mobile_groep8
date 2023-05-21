import 'package:easypark_app/extensions/geopoint_extensions.dart';
import 'package:easypark_app/global/global.dart';
import 'package:easypark_app/model/location.dart';
import 'package:easypark_app/services/location_service.dart';
import 'package:easypark_app/ui/elements/headerbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  late final LocationService _service;
  late Stream<QuerySnapshot<Object?>>? _locationsStream;
  @override
  initState() {
    super.initState();
    _service = LocationService();
    _locationsStream = _service.getLocationsStream();
  }

  ButtonStyle _blueRounded(BuildContext context) => ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.25,
            MediaQuery.of(context).size.height * 0.05),
        disabledBackgroundColor: Colors.white24,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
      );

  ButtonStyle _grayRounded(BuildContext context) => ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.25,
            MediaQuery.of(context).size.height * 0.05),
        foregroundColor: Colors.white60,
        backgroundColor: Colors.black45,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
      );

  void _removeExpiredLocations(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    for (var doc in snapshot.data!.docs) {
      Location l = Location.fromJson(doc.data() as Map<String, dynamic>);
      if (l.timestamp.toDate().isBefore(DateTime.now())) {
        _service.deleteLocation(doc.id);
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

  Location setSpotReserved(Location l) {
    if (!l.isReserved) {
      l.isReserved = true;
    }
    return l;
  }

  Future<DateTime?> _selectDate(DateTime start) async {
    final DateTime? date = await showDatePicker(
        initialEntryMode: DatePickerEntryMode.input,
        context: context,
        initialDate: start,
        firstDate: start,
        lastDate: DateTime.now().add(Duration(days: 1)));
    return date;
  }

  Future<TimeOfDay?> _selectTime() async {
    TimeOfDay? newTime;
    newTime = await showTimePicker(
      confirmText: 'Confirm your reservation',
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.inputOnly,
    );
    return newTime;
  }

  Location _positionToLocation(LatLng pos, DateTime time) {
    return Location(
        GeoPoint(pos.latitude, pos.longitude),
        globalSessionData.userEmail as String,
        Timestamp.fromDate(time),
        false,
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
      _service.addLocation(_positionToLocation(pos, newDate));
    }
  }

  Future<DateTime?> selectDateTime() async {
    DateTime? date = await _selectDate(DateTime.now());
    TimeOfDay? time;
    if (date != null) {
      time = await _selectTime();
    }
    if (date != null && time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    return null;
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
                          style: _blueRounded(context),
                          child: const Text('Reserve'),
                          onPressed: () {
                            Navigator.pop(context);
                            createNewLocation(latlng);
                          }),
                    ),
                    SizedBox(
                      child: ElevatedButton(
                          style: _grayRounded(context),
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

  String _formatDateTime(DateTime d) {
    if (d.day == DateTime.now().day) {
      return DateFormat('HH:mm').format(d);
    } else {
      return '${DateFormat('HH:mm').format(d)} tomorrow';
    }
  }

  void _confirmDeparture(DocumentSnapshot doc) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Departure'),
            content: const Text('Are you sure you want to leave your spot?'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(context);
                  },
                  child: const Text('Cancel departure')),
              ElevatedButton(
                  onPressed: () {
                    _service.deleteLocation(doc.id);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(context);
                  },
                  child: const Text('Confirm departure'))
            ],
          );
        });
  }

  void showOwnMarkerMenu(DocumentSnapshot doc) {
    Location location = docToLocation(doc);
    Column reserved =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
              'You reserved this spot until ${_formatDateTime(location.timestamp.toDate())}'),
        ],
      ),
      ElevatedButton(
          style: _blueRounded(context),
          onPressed: () {
            _confirmDeparture(doc);
          },
          child: const Text('Depart')),
    ]);

    Column notReserved =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
              'You reserved this spot until ${_formatDateTime(location.timestamp.toDate())}'),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              style: _blueRounded(context),
              onPressed: () {
                _confirmDeparture(doc);
              },
              child: const Text('Depart')),
          ElevatedButton(
              style: _blueRounded(context),
              onPressed: () async {
                DateTime? newTime = await selectDateTime();
                if (newTime != null) {
                  _service.setLocationTime(doc.id, newTime);
                }
                Navigator.of(context).pop(context);
              },
              child: const Text('Extend Reservation')),
        ],
      )
    ]);
    if (location.isReserved) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: reserved));
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: notReserved));
    }
  }

  void showOthersMarkerMenu(DocumentSnapshot doc) {
    Location location = docToLocation(doc);
    Column notReserved =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
              'Reserved until ${_formatDateTime(location.timestamp.toDate())}'),
        ],
      ),
      ElevatedButton(
          style: _blueRounded(context),
          onPressed: () {
            if (!location.isReserved) {
              Navigator.of(context).pop();
              _service.setLocationReserved(doc.id, true);
            } else {
              null;
            }
          },
          child: const Text('Reserve this location'))
    ]);

//Reserved
    Column reserved = Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text('Reserved until ${_formatDateTime(location.timestamp.toDate())}'),
      ],
    );
    //ReservedByUser
    Column reservedByUser =
        Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
              'Reserved until ${_formatDateTime(location.timestamp.toDate())}'),
        ],
      ),
      ElevatedButton(
          style: _blueRounded(context),
          onPressed: () {
            if (location.isReserved) {
              Navigator.of(context).pop();
              _service.setLocationReserved(doc.id, false);
            } else {
              null;
            }
          },
          child: const Text('Cancel Reservation'))
    ]);
    if (!location.isReserved) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: notReserved,
              ));
    } else if (location.isReserved &&
        location.nextMail == globalSessionData.userEmail) {
      showModalBottomSheet(
          context: context,
          builder: (context) => SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: reservedByUser,
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
    //_removeExpiredLocations(snapshot);
    for (var doc in snapshot.data!.docs) {
      Location location = docToLocation(doc);
      if (location.timestamp.toDate().isBefore(DateTime.now())) {
        markers.removeWhere(
            (marker) => marker.point == location.geoPoint.toLatLng());
      }
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
      } else if (!location.isReserved &&
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
      } else if (!location.isReserved) {
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
