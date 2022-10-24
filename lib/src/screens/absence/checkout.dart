import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/models/data_checkin.dart';
import 'package:attendance_app/src/utils/services/relogin.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:attendance_app/src/utils/widget/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';

class Checkout extends StatefulWidget {
  final String address;
  final double lat;
  final double long;

  Checkout({required this.address, required this.lat, required this.long});
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late String _text;
  late String _token;
  late String _fbtoken;
  late bool isCheckin;
  late int _projectId;
  late String _imagetoCheckout;
  ApiService _apiService = ApiService();
  final RoundedLoadingButtonController _button =
      RoundedLoadingButtonController();
  late SharedPreferences logindata;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _token = logindata.getString('token')!;
        _fbtoken = logindata.getString('fbtoken')!;
        isCheckin = logindata.getBool('isCheckin')!;
        _projectId = logindata.getInt('projectId')!;
        _imagetoCheckout = logindata.getString('imageCheckin')!;
      });
    }
    await getProject();
  }

  getProject() {
    if (_projectId == 1) {
      setState(() => _text = 'WFO (Work From Office)');
    } else if (_projectId == 2) {
      setState(() => _text = 'WFH (Work From Home)');
    } else {
      setState(() => _text = 'WFC (Work From Client)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _projectId == null
        ? Loader()
        : WillPopScope(
            onWillPop: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/HomePage', (Route<dynamic> route) => false);
              return Future.value(false);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 15.0),
                  child: Text(
                    'Check Out',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 200.0,
                ),
                checkoutButton()
              ],
            ),
          );
  }

  Widget checkoutButton() {
    return Builder(
      builder: (context) => RoundedLoadingButton(
        color: new Color(0xFFff7f00),
        successColor: new Color(0xFFff7f00),
        child: Text('SUBMIT', style: TextStyle(color: Colors.white)),
        controller: _button,
        onPressed: () async {
          var checkOut = await dataToCheckOut();
          _apiService.postCheckOut(checkOut, _token).then((result) {
            if (result == 'timeout') {
              _button.reset();
              onTimeout();
            } else {
              var jsondata = json.decode(result);
              var statusCode = jsondata['status'];
              if (statusCode == 'success') {
                _button.success();
                onSuccess();
              } else if (statusCode == 401) {
                _button.reset();
                onReLogin(jsondata);
              } else if (statusCode == 400) {
                _button.reset();
                locationFailed();
              } else {
                _button.reset();
                onFailed(jsondata);
              }
            }
          });
        },
      ),
    );
  }

  onReLogin(jsondata) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
                title: 'Failed to check out',
                content: jsondata['message'],
                isWarning: false,
                isButton: true,
                onpressed: () async {
                  await ReLogin().onLogout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/LoginScreen', (Route<dynamic> route) => false);
                }),
          );
        });
  }

  dataToCheckOut() {
    Geolocation geolocation = Geolocation(lat: widget.lat, long: widget.long);
    CheckIn checkOut = CheckIn(
      projectId: _projectId,
      location: widget.address.toString(),
      image: 'data:image/png;base64,' + _imagetoCheckout,
      fbtoken: _fbtoken,
      geolocation: geolocation,
    );
    return checkOut;
  }

  onTimeout() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
              title: 'Connection Failed',
              content:
                  'There is no response from server, or please check your connectivity',
              isWarning: false,
              isButton: true,
              onpressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/HomePage'),
                );
              },
            ),
          );
        });
  }

  onSuccess() {
    print('Successfully Checkout!');
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Check out successfully',
            content: 'Thank you',
            isWarning: false,
            isButton: true,
            onpressed: () {
              logindata.setBool('isCheckin', false);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/HomePage', (Route<dynamic> route) => false);
            },
          );
        });
  }

  onFailed(jsondata) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to check out',
            content: 'Please try again',
            isWarning: true,
            // warningText: jsondata.toString(),
            warningText: jsondata['message'],
            isButton: false,
          );
        });
  }

  locationFailed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to check in',
            content: 'Sorry, your location is not accurate',
            isWarning: false,
            isButton: false,
          );
        });
  }
}
