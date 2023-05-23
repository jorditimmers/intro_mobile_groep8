import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easypark_app/ui/elements/headerbar.dart';
import 'package:easypark_app/ui/pages/login/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../../global/global.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final newPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();

  Widget buildOldPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Old Password',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF_Pro'),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextField(
            controller: oldPasswordController,
            obscureText: true,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
                hintText: 'Old Password',
                hintStyle: TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Widget buildNewPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'New Password',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF_Pro'),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
              ]),
          height: 60,
          child: TextField(
            controller: newPasswordController,
            obscureText: true,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
                hintText: 'New Password',
                hintStyle: TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Widget buildSaveButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(5),
            backgroundColor: MaterialStateProperty.all(Colors.blue),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
            padding: MaterialStateProperty.all(EdgeInsets.all(25))),
        onPressed: () => {checkAndSave()},
        child: (Text(
          'SAVE',
          style: (TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF_Pro')),
        )),
      ),
    );
  }

  Widget buildDeleteAccountButton() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(5),
            backgroundColor: MaterialStateProperty.all(Colors.red),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
            padding: MaterialStateProperty.all(EdgeInsets.all(25))),
        onPressed: () => {showComfirmDialog(context)},
        child: (Text(
          'DELETE ACCOUNT',
          style: (TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF_Pro')),
        )),
      ),
    );
  }

  Future<void> deleteAccount() async {
    final inst = await FirebaseFirestore.instance;
    final col =
        inst.collection('Users').doc(globalSessionData.userEmail).delete();

    final col2 = inst
        .collection('Cars')
        .where('OwnerEmail', isEqualTo: globalSessionData.userEmail)
        .get()
        .then((snapshot) => {
              for (var s in snapshot.docs) {s.reference.delete()}
            });

    final col3 = inst
        .collection('Locations')
        .where('OwnerEmail', isEqualTo: globalSessionData.userEmail)
        .get()
        .then((snapshot) => {
              for (var s in snapshot.docs) {s.reference.delete()}
            });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => loginPage()));
  }

  showComfirmDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("YES"),
      onPressed: () {
        deleteAccount();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete this account"),
      content: Text("Are you sure you want to delete this account?"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Invalid user"),
      content: Text("E-Mail and password do not match."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  checkAndSave() async {
    //These are for debug reasons only
    print('Password: ' + oldPasswordController.text);

    bool userExists = await isUserPresent(
        globalSessionData.userEmail as String, oldPasswordController.text);
    if (userExists) {
      print("User correct!");
      FirebaseFirestore.instance
          .collection('Users')
          .doc(globalSessionData.userEmail)
          .update({'Password': newPasswordController.text});
    } else {
      print("Password and email do not match.");
      showAlertDialog(context);
    }

    oldPasswordController.clear();
    newPasswordController.clear();
  }

  Future<bool> isUserPresent(String mail, String pwd) async {
    final user = await FirebaseFirestore.instance
        .collection('Users')
        .where('Email', isEqualTo: mail)
        .where('Password', isEqualTo: pwd)
        .limit(1)
        .get();
    return user.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'EasyPark',
            style: const TextStyle(fontFamily: 'SF_Pro', fontSize: 30),
          ),
          leading: IconButton(
            color: Colors.blue,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          foregroundColor: Colors.blue,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle_rounded,
                size: 200,
                color: Colors.blue,
              ),
              Text(
                globalSessionData.userEmail as String,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF_Pro'),
              ),
              SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 5),
                    buildOldPassword(),
                    SizedBox(height: 5),
                    buildNewPassword(),
                    SizedBox(height: 5),
                    buildSaveButton(),
                    buildDeleteAccountButton(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
