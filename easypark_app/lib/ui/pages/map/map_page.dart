import 'package:easypark_app/ui/headerbar/headerbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  void getAllMarkers() {
    FirebaseFirestore.instance.collection('Location').get().then(
      (querySnapshot) {
        print("Successfully completed");
        for (var docSnapshot in querySnapshot.docs) {
          setState(() {
            _markers.add(Marker(
                point: LatLng(docSnapshot.get('Location').latitude,
                    docSnapshot.get('Location').longitude),
                builder: (context) {
                  return Icon(
                    Icons.location_on_rounded,
                    size: 42,
                    color: Colors.green,
                  );
                }));
          });
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  final List<Marker> _markers = [];
  DateTime _time = DateTime.now();

  final MapController _mapController = MapController();

  bool isReserved = false;

  void _addMarker(LatLng pos) {
    setState(() {});
    _markers.add(Marker(
        point: pos,
        builder: (context) => const Icon(
              Icons.location_on_rounded,
              size: 42,
              color: Colors.redAccent,
            )));
  }

  void _removeMarkerFromDatabase(LatLng pos, DateTime time) {
    FirebaseFirestore.instance.collection('Location').doc();
  }

  void _removeMarker() {
    setState(() {
      _markers.removeLast();
    });
  }

  void writeMarkerToDatabase(LatLng pos, DateTime time) {
    FirebaseFirestore.instance.collection('Location').add({
      'Location': GeoPoint(pos.latitude, pos.longitude),
      'Time': Timestamp.fromDate(time)
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
      setState(() {
        _time = newDate;
      });
    } else {
      _removeMarker();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerBar(),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          onMapReady: getAllMarkers,
          minZoom: 18,
          maxZoom: 18,
          maxBounds: LatLngBounds(
              LatLng(51.22978, 4.41376), LatLng(51.22765, 4.41789)),
          onTap: (tp, latlng) {
            _addMarker(latlng);
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
                                    isReserved = true;
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
                }).whenComplete(() => {
                  _removeMarker(),
                  if (isReserved) {_addMarker(latlng)},
                  isReserved = false
                });
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
