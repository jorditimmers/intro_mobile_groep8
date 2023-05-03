import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Location {
  GeoPoint geoPoint;
  Timestamp timestamp;
  String ownerEmail;

  Location(this.geoPoint, this.ownerEmail, this.timestamp);

  String toString() => "Location<$geoPoint>";

  factory Location.fromJson(Map<String, dynamic> json) =>
      _locationFromJson(json);

  Map<String, dynamic> toJson() => _locationToJson(this);

  static Location _locationFromJson(Map<String, dynamic> json) {
    return Location(
      json['Location'] as GeoPoint,
      json['OwnerEmail'] as String,
      json['Time'] as Timestamp,
    );
  }

  Map<String, dynamic> _locationToJson(Location instance) => <String, dynamic>{
        'Location': instance.geoPoint,
        'OwnerEmail': instance.ownerEmail,
        'Time': instance.timestamp,
      };
}
