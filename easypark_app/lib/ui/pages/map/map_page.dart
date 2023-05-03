import 'package:easypark_app/extensions/geopoint_extensions.dart';
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
  Future<String> getCurrentUser() async {
    //final prefs = await SharedPreferences.getInstance();
    //prefs.setString('userEmail', 'kaasbalsnuiver');
    return 'kaasbaas';
  }

  List<Location> _locations = [];

  Future<List<Location>> getAllLocations() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Locations').get();
    print(querySnapshot);
    List<Location> locations = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Location.fromJson(data);
    }).toList();
    print(locations);
    return locations;
  }

  DateTime _timeStampToDateTime(Timestamp t) => t.toDate();

  void onMapReady() {
    setState(() {
      _setMarkersOnLocations();
    });
  }

  final List<Marker> _markers = [];

  final MapController _mapController = MapController();

  bool isReserved = false;

  void _addTempMarker(LatLng pos) {
    setState(() {});
    _markers.add(Marker(
        point: pos,
        builder: (context) => const Icon(
              Icons.location_on_rounded,
              size: 42,
              color: Colors.redAccent,
            )));
  }

  void _removeTempMarker() {
    setState(() {
      _markers.removeLast();
    });
  }

  void writeMarkerToDatabase(LatLng pos, DateTime time) {
    FirebaseFirestore.instance.collection('Locations').add({
      'Location': GeoPoint(pos.latitude, pos.longitude),
      'OwnerEmail': 'test',
      'Time': Timestamp.fromDate(time),
    });
  }

  void _selectTime(LatLng pos) async {
    TimeOfDay? newTime;
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 14)));

    if (date != null) {
      newTime = await showTimePicker(
        confirmText: 'Confirm your reservation',
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dial,
      );
    }
    if (newTime != null) {
      DateTime newDate = DateTime(
          date!.year, date.month, date.day, newTime.hour, newTime.minute);
      writeMarkerToDatabase(pos, newDate);
    }
    _setMarkersOnLocations();
  }

  void _setMarkersOnLocations() async {
    _locations = await getAllLocations();
    for (var location in _locations) {
      setState(() {
        if (location.ownerEmail == 'kaasbaas') {
          _markers.add(Marker(
              point: location.geoPoint.toLatLng(),
              builder: (contex) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Column(children: [
                                Text('Reserved until {}'),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: Text('Indicate Departure'))
                              ]),
                            ));
                  },
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 42,
                    color: Colors.green,
                  ),
                );
              }));
        } else {
          _markers.add(Marker(
              point: location.geoPoint.toLatLng(),
              builder: (contex) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
                              child:
                                  Column(children: [Text('Reserved until {}')]),
                            ));
                  },
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 42,
                    color: Colors.blue,
                  ),
                );
              }));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerBar(context),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          onMapReady: onMapReady,
          minZoom: 18,
          maxZoom: 18,
          maxBounds: LatLngBounds(
              LatLng(51.22978, 4.41376), LatLng(51.22765, 4.41789)),
          onTap: (tp, latlng) {
            _addTempMarker(latlng);
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
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.blue,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                      ),
                                      child: const Text('Reserve'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _selectTime(latlng);
                                      }),
                                ),
                                SizedBox(
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white60,
                                        backgroundColor: Colors.black45,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                      ),
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                )
                              ],
                            ),
                          ));
                    })
                .whenComplete(
                    () => {_setMarkersOnLocations(), _removeTempMarker()});
          },
          center: LatLng(51.22857, 4.41646),
          zoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'edu.ap.mobilegroep8',
          ),
          MarkerLayer(markers: _markers)
        ],
      ),
    );
  }
}
