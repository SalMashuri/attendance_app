import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/models/data_login.dart';
import 'package:attendance_app/src/screens/warning/warning.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:attendance_app/src/utils/widget/dialog/exitapp_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db/database.dart';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';

const _bgColor = Color(0xFFFF9800);

final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  loc.Location locationGps = loc.Location();
  ApiService _apiService = ApiService();
  bool _isFieldPassValid = true;
  bool _isFieldEmailValid = true;
  TextEditingController _controllerPass = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  late SharedPreferences logindata;
  late bool isLogin;
  bool loadingPage = false;

  @override
  void initState() {
    _checkGps();
    super.initState();
  }

  Future _checkGps() async {
    logindata = await SharedPreferences.getInstance();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool serviceStatusResult = await locationGps.requestService();
      if (serviceStatusResult == false) {
        if (Platform.isAndroid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WarningPage(
                page: 'LoginScreen',
              ),
            ),
          );
        }
      }
    }
  }

  _save(
      String name,
      String email,
      String statuss,
      String homeaddress,
      String homelatlong,
      String officeaddress,
      String officelatlong,
      String images,
      String token) async {
    Datauser datauser = Datauser();
    datauser.name = name;
    datauser.email = email;
    datauser.status = statuss;
    if (homeaddress != null) {
      datauser.homeAddress = homeaddress;
    }
    if (homeaddress != null) {
      datauser.homeAddress = homeaddress;
    }
    if (homelatlong != null) {
      datauser.homeLatlong = homelatlong;
    }
    if (officeaddress != null) {
      datauser.officeAddress = officeaddress;
    }
    if (officelatlong != null) {
      datauser.officeLatlong = officelatlong;
    }
    if (images != null) {
      datauser.image = images;
    }
    datauser.token = token;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(datauser);
    print('inserted row: $id');
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context, builder: (context) => ExitApp())) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
              backgroundColor: _bgColor,
              title: Text('Log In', style: TextStyle(color: Colors.white)),
            ),
            key: _scaffoldState,
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        kLogoMSG,
                        width: 150,
                        height: 150,
                      ),
                      nameTest(),
                      SizedBox(
                        height: 15.0,
                      ),
                      passTest(),
                      SizedBox(
                        height: 40.0,
                      ),
                      registerButton(),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Widget nameTest() {
    return TextField(
      controller: _controllerEmail,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        hintText: 'Masukkan Email',
        filled: true,
        fillColor: Colors.white,
        errorText: _isFieldEmailValid == null || _isFieldEmailValid
            ? null
            : "Email is required",
      ),
      onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != _isFieldEmailValid) {
          setState(() => _isFieldEmailValid = isFieldValid);
        }
      },
    );
  }

  Widget passTest() {
    return TextField(
      controller: _controllerPass,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        hintText: 'Masukkan Password',
        filled: true,
        fillColor: Colors.white,
        errorText: _isFieldPassValid == null || _isFieldPassValid
            ? null
            : "Pass is required",
      ),
      onChanged: (value) {
        bool isFieldValid = value.trim().isNotEmpty;
        if (isFieldValid != _isFieldPassValid) {
          setState(() => _isFieldPassValid = isFieldValid);
        }
      },
    );
  }

  Widget registerButton() {
    return Builder(
      builder: (context) => RoundedLoadingButton(
          color: Colors.blue,
          child: Text('Log In', style: TextStyle(color: Colors.white)),
          controller: _btnController,
          onPressed: () {
            if (_isFieldPassValid == null ||
                _isFieldEmailValid == null ||
                !_isFieldPassValid ||
                !_isFieldEmailValid) {
              _btnController.reset();
              _scaffoldState.currentState!.showSnackBar(
                SnackBar(
                  content: Text("Please fill all field above"),
                ),
              );
              return;
            }
            String email = _controllerEmail.text.toString();
            String password = _controllerPass.text.toString();
            DataLogin datalogin = DataLogin(email: email, password: password);
            _apiService.postLoginData(datalogin).then((result) {
              if (result == 'timeout') {
                _btnController.reset();
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: PopDialog(
                          title: 'Connection Failed',
                          content:
                              'There is no response on server or please check your connectivity',
                          isWarning: false,
                          isButton: true,
                          onpressed: () => Navigator.pop(context),
                        ),
                      );
                    });
              } else {
                var dataJson = json.decode(result);
                if (dataJson['status'] == 200) {
                  String name = dataJson['data']['name'];
                  String email = dataJson['data']['email'];
                  String statuss = dataJson['data']['status'].toString();
                  String homeaddress = dataJson['data']['home_address'];
                  String homelatlong = dataJson['data']['home_latlong'];
                  String officeaddress = dataJson['data']['office_address'];
                  String officelatlong = dataJson['data']['office_latlong'];
                  String images =
                      dataJson['data']['full_path_image'].toString();
                  String token = dataJson['token'].toString();
                  _save(name, email, statuss, homeaddress, homelatlong,
                      officeaddress, officelatlong, images, token);
                  logindata.setBool('isLogin', true);
                  logindata.setString('token', token);
                  logindata.setString('name', name);
                  logindata.setString('email', email);
                  logindata.setString('imageUrl', images);
                  print('Successfully log in!');
                  _btnController.success();
                  _controllerPass.clear();
                  _controllerEmail.clear();
                  Navigator.pushReplacementNamed(context, '/HomePage');
                  _btnController.reset();
                } else {
                  _btnController.reset();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PopDialog(
                          title: 'Failed to log in',
                          content: dataJson['message'],
                          isWarning: false,
                          isButton: false,
                        );
                      });
                }
              }
            });
          }),
    );
  }
}
