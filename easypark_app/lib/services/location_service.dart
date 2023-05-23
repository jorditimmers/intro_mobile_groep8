import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/location.dart';

class LocationService {
  late final CollectionReference locationsRef;

  late final QuerySnapshot _snapshot;

  static final LocationService _instance = LocationService._internal();
  factory LocationService() {
    return _instance;
  }
  LocationService._internal() {
    locationsRef = FirebaseFirestore.instance.collection('Locations');
    setSnapShot();
  }

  void setSnapShot() async {
    _snapshot = await locationsRef.get();
  }

  Future<void> addLocation(Location location) async {
    try {
      await locationsRef.add(location.toJson());
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> deleteLocation(String locationId) async {
    try {
      await locationsRef.doc(locationId).delete();
    } catch (e) {
      print("Error: $e");
    }
  }

  Stream<QuerySnapshot<Object?>> getLocationsStream() {
    return locationsRef.snapshots();
  }

  Future<List<Location>> getLocationsFromStream() async {
    return _snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Location.fromJson(data);
    }).toList();
  }

  Future<void> setLocationTime(String locationId, DateTime newTime) {
    return locationsRef.doc(locationId).update({'Time': newTime});
  }

  Future<void> setLocationReserved(String locationId, bool b) {
    return locationsRef.doc(locationId).update({'IsReserved': b});
  }

  Future<void> setLocationNextMail(String locationId, String? nextMail) {
    return locationsRef.doc(locationId).update({'NextMail': nextMail});
  }
}
