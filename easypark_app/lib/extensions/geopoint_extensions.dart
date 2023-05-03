import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

extension LatLngCasting on GeoPoint {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}
