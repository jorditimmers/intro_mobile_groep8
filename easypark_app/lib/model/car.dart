import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  //Entity fields
  String Brand;
  String Model;
  String Color;
  String OwnerEmail;

  //Constructor
  Car(this.Brand, this.Model, this.Color, this.OwnerEmail);

  //Factory constructor
  factory Car.fromJson(Map<String, dynamic> json) => _carFromJson(json);

  //Map
  Map<String, dynamic> toJson() => _carToJson(this);

  @override
  String toString() => 'Car<$Model>';
}

// Json to User
Car _carFromJson(Map<String, dynamic> json) {
  return Car(json['Brand'] as String, json['Model'] as String,
      json['Color'] as String, json['OwnerEmail'] as String);
}

// User to Json
Map<String, dynamic> _carToJson(Car instance) => <String, dynamic>{
      'Brand': instance.Brand,
      'Model': instance.Model,
      'Color': instance.Color,
      'OwnerEmail': instance.OwnerEmail
    };
