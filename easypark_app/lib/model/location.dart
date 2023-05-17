import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Location {
  GeoPoint geoPoint;
  Timestamp timestamp;
  String ownerEmail;
  Timestamp? nextTimestamp;
  String? nextOwnerEmail;

  Location(this.geoPoint, this.ownerEmail, this.timestamp, this.nextTimestamp,
      this.nextOwnerEmail);

  String toString() => "Location<$geoPoint>";

  factory Location.fromJson(Map<String, dynamic> json) =>
      _locationFromJson(json);

  Map<String, dynamic> toJson() => _locationToJson(this);

  static Location _locationFromJson(Map<String, dynamic> json) {
    return Location(
        json['Location'] as GeoPoint,
        json['OwnerEmail'] as String,
        json['Time'] as Timestamp,
        json['NextTimestamp'] as Timestamp?,
        json['NextOwnerEmail'] as String?);
  }

  Map<String, dynamic> _locationToJson(Location instance) => <String, dynamic>{
        'Location': instance.geoPoint,
        'OwnerEmail': instance.ownerEmail,
        'Time': instance.timestamp,
        'NextTimestamp': instance.nextTimestamp,
        'NextOwnerEmail': instance.nextOwnerEmail
      };
}
