import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/widget/dialog/exitapp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class WarningVersion extends StatefulWidget {
  @override
  _WarningVersionState createState() => _WarningVersionState();
}

class _WarningVersionState extends State<WarningVersion> {
  late SharedPreferences logindata;
  late String text;

  @override
  void initState() {
    super.initState();
  }

  _launchURL(String linkurl) async {
    final url = linkurl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _onWillPopp() async {
    return (await showDialog(
            context: context, builder: (context) => ExitApp())) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments != null) print(arguments['directtoLink']);
    return WillPopScope(
        onWillPop: _onWillPopp,
        child: Scaffold(
            backgroundColor: kBgWarningColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Image.asset(
                      kLogoMSG,
                      height: 150,
                      width: 150,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      'Sorry, you are currently using the old version. Please update into the latest version',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30.0),
                    child: ButtonTheme(
                      buttonColor: Color(0xFFff7f00),
                      child: RaisedButton(
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        onPressed: () => _launchURL(arguments['directtoLink']),
                        child: Text(
                          'Update App',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
