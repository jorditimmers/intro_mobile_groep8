import 'package:easypark_app/ui/headerbar/headerbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //List<Marker> markers = [];
  final MapController mapController = MapController.withPosition(
    initPosition: GeoPoint(
      latitude: 51.2288,
      longitude: 4.41562,
    ), //AP Hogeschool Campus Ellermanstraat
    areaLimit: BoundingBox(
      east: 4.41721,
      north: 51.22978,
      south: 51.22786,
      west: 4.41366,
    ),
  );

  bool isReserved = false;

  dynamic addMarkerOnTap() {
    mapController.listenerMapSingleTapping.addListener(() {
      if (mapController.listenerMapSingleTapping.value != null) {
        GeoPoint p = mapController.listenerMapSingleTapping.value!;
        mapController.addMarker(p);
        showModalBottomSheet(
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              child: Text('Reserve'),
                              onPressed: () {
                                isReserved = true;
                                Navigator.pop(context);
                              }),
                        ),
                        SizedBox(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white60,
                                backgroundColor: Colors.black45,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        )
                      ],
                    ),
                  ));
            }).then((value) => {
              mapController.removeMarker(p),
              if (isReserved)
                {
                  mapController.addMarker(p,
                      markerIcon: const MarkerIcon(
                        icon: Icon(
                          Icons.person_pin_circle,
                          color: Colors.lightGreen,
                          size: 84,
                        ),
                      ))
                },
              isReserved = false
            });
      }
    });
  }

  void indicateDeparture() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: headerBar(),
      body: OSMFlutter(
        onMapIsReady: addMarkerOnTap(),
        onGeoPointClicked: (p) {
          showModalBottomSheet(
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                          onPressed: () {
                            mapController.removeMarker(p);
                            Navigator.pop(context);
                          },
                          child: Text('Depart'),
                        ),
                      ),
                      SizedBox(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black45,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                          onPressed: () {
                            mapController.removeMarker(p);
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                      )
                    ],
                  )),
                );
              });
        },
        controller: mapController,
        trackMyPosition: false,
        initZoom: 18,
        minZoomLevel: 18,
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
    );
  }
}
