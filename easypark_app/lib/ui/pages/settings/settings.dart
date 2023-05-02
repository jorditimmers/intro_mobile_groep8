import 'package:easypark_app/ui/pages/settings/carsettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Settings',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'SF_Pro'),
          ),
          leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: Text('Account Settings'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.car_repair_outlined),
                  title: Text('Manage Cars'),
                  value: Text('Add/Remove cars that you own'),
                  onPressed: (context) => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CarSettings()),
                    ) //OPEN MENU HERE
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
