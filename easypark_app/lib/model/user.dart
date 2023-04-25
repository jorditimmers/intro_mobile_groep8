import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  //Entity fields
  String Email;
  String Password;
  String Username;

  //Constructor
  User(this.Email, this.Password, this.Username);

  //Factory constructor
  factory User.fromJson(Map<String, dynamic> json) => _userFromJson(json);

  //Map
  Map<String, dynamic> toJson() => _userToJson(this);

  @override
  String toString() => 'User<$Username>';
}

// Json to User
User _userFromJson(Map<String, dynamic> json) {
  return User(
    json['Password'] as String,
    json['Email'] as String,
    json['Username'] as String,
  );
}

// User to Json
Map<String, dynamic> _userToJson(User instance) => <String, dynamic>{
      'Email': instance.Email,
      'Password': instance.Password,
      'Username': instance.Username,
    };
