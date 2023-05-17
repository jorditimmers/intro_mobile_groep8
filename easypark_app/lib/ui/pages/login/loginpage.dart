import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:easypark_app/ui/elements/headerbar.dart';
import 'package:easypark_app/ui/pages/home/homepage.dart';
import 'package:easypark_app/ui/pages/login/registerpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:easypark_app/global/global.dart';

import '../../../model/user.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  bool isRememberMe = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
      content: Text(
          "This user does not exist. Check if you filled in the correct email and/or password."),
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

  Future<void> checkAndLogin() async {
    //These are for debug reasons only
    print('email: ' + emailController.text);
    print('Password: ' + passwordController.text);

    var bytesToHash = utf8.encode(passwordController.text);
    var sha256Digest = sha256.convert(bytesToHash);

    bool userExists =
        await isUserPresent(emailController.text, sha256Digest.toString());
    if (userExists) {
      print("User exists!");
      globalSessionData.userEmail = emailController.text;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(
                  title: 'EasyPark',
                )),
      );
    } else {
      print("User does not exist.");
      showAlertDialog(context);
    }

    emailController.clear();
    passwordController.clear();
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

  Widget buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'E-Mail',
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
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                hintText: 'E-Mail',
                hintStyle: TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Widget buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
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
            controller: passwordController,
            obscureText: true,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.black38)),
          ),
        )
      ],
    );
  }

  Widget buildLoginButton() {
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
        onPressed: () => {checkAndLogin()},
        child: (Text(
          'LOGIN',
          style: (TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF_Pro')),
        )),
      ),
    );
  }

  Widget buildRememberCb() {
    return Container(
      height: 20,
      child: Row(children: <Widget>[
        Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: isRememberMe,
              checkColor: Colors.blue,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  isRememberMe = value!;
                });
              },
            )),
        Text(
          'Remember me',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF_Pro'),
        ),
      ]),
    );
  }

  Widget buildSignUpBtn() {
    return GestureDetector(
      onTap: () => {
        print("Sign up pressed"),
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const registerPage()))
      },
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF_Pro')),
          TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                  color: Colors.black26,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF_Pro'))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      const Color(0xcc007AFF),
                      const Color(0xff007AFF),
                      const Color(0x99007AFF),
                      const Color(0x66007AFF),
                      const Color.fromARGB(42, 0, 123, 255),
                      const Color.fromARGB(6, 0, 123, 255),
                    ])),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 120),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('EasyPark',
                          style: const TextStyle(
                              fontFamily: 'SF_Pro',
                              fontSize: 80,
                              color: Colors.white)),
                      SizedBox(height: 50),
                      buildEmail(),
                      SizedBox(height: 20),
                      buildPassword(),
                      SizedBox(height: 10),
                      // buildRememberCb(),
                      buildLoginButton(),
                      buildSignUpBtn()
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
