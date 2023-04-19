import 'package:easypark_app/ui/headerbar/headerbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapPage extends StatelessWidget {
  final MapController mapController = MapController.withPosition(
    initPosition: GeoPoint(
      latitude: 51.23024625125789,
      longitude: 4.416128099999962,
    ), //AP Hogeschool Campus Ellermanstraat
    areaLimit: BoundingBox(
      east: 25,
      north: 25,
      south: 25,
      west: 25,
    ),
  );

  MapPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: headerBar(),
      body: OSMFlutter(
        controller: mapController,
        trackMyPosition: false,
        initZoom: 12,
        minZoomLevel: 10,
        maxZoomLevel: 19,
        stepZoom: 1.0,
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_history_rounded,
              color: Colors.red,
              size: 48,
            ),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(
              Icons.double_arrow,
              size: 48,
            ),
          ),
        ),
        roadConfiguration: const RoadOption(
          roadColor: Colors.yellowAccent,
        ),
        markerOption: MarkerOption(
            defaultMarker: const MarkerIcon(
          icon: Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 56,
          ),
        )),
      ),
    ));
  }
}
