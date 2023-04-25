import 'package:easypark_app/strings.dart';
import 'package:flutter/material.dart';

headerBar() => AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'SF_Pro', fontSize: 30),
      ),
      foregroundColor: Colors.blue,
      leading: IconButton(
        onPressed: () {
          //OPEN MENU HERE
        },
        icon: Icon(
          Icons.settings_outlined,
          color: Colors.blue,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              //OPEN ACCOUNT SETTINGS HERE
            },
            icon: Icon(Icons.account_circle_outlined))
      ],
    );
