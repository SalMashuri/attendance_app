import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';

class WarningPage extends StatefulWidget {
  final String? page;
  WarningPage({this.page});
  @override
  _WarningPageState createState() => _WarningPageState();
}

class _WarningPageState extends State<WarningPage> {
  loc.Location locationGps = loc.Location();
  late SharedPreferences logindata;

  @override
  void initState() {
    super.initState();
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      bool serviceStatusResult = await locationGps.requestService();
      if (serviceStatusResult == false) {
      } else {
        Navigator.pushReplacementNamed(context, '/${widget.page}');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/${widget.page}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
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
                      'Sorry, you have to anable the location to access this app',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30.0),
                    child: FlatButton(
                      color: Colors.orange,
                      child: Text('Yes'),
                      onPressed: () {
                        _checkGps();
                      },
                    ),
                  ),
                ],
              ),
            )));
  }
}
