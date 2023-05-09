import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark_app/strings.dart';
import 'package:easypark_app/ui/pages/account/account.dart';
import 'package:easypark_app/ui/pages/settings/settings.dart';
import 'package:flutter/material.dart';

headerBar(BuildContext context) => AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'SF_Pro', fontSize: 30),
      ),
      foregroundColor: Colors.blue,
      leading: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          ); //OPEN MENU HERE
        },
        icon: Icon(
          Icons.settings_outlined,
          color: Colors.blue,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage()),
              ); //OPEN ACCOUNT SETTINGS HERE
            },
            icon: Icon(Icons.account_circle_outlined))
      ],
    );
