import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/db/database.dart';
import 'package:attendance_app/src/screens/setting/edit_screen.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  final RoundedLoadingButtonController _btnController1 =
      new RoundedLoadingButtonController();
  ApiService _apiService = ApiService();
  String _imageUser = "";
  String _nameUser = "";
  String _emailUser = "";
  String _homeUser = "";
  String _officeUser = "";
  late SharedPreferences logindata;
  late String _token;

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _read() async {
    logindata = await SharedPreferences.getInstance();
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    Datauser? datauser = await helper.queryDatauser(rowId);
    if (datauser != null) {
      if (!mounted) return;
      setState(() {
        _token = logindata.getString('token')!;
        _nameUser = datauser.name!;
        _emailUser = datauser.email!;
        _homeUser = datauser.homeAddress!;
        _officeUser = datauser.officeAddress!;
        // _imageUser = datauser.image;
        datauser.image ==
                "https://attendance.msg.co.id/backend/uploads/images/user-default.jpg"
            ? _imageUser = ""
            : _imageUser = datauser.image!;
      });
      logindata.setString('homeUpdate', datauser.homeAddress!);
      logindata.setString('officeUpdate', datauser.officeAddress!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _nameUser == null
        ? Center(
            child: Container(
            padding: EdgeInsets.all(20.0),
            color: Colors.orange,
            height: 75,
            width: 75,
            child: LoadingIndicator(
              backgroundColor: Colors.white,
              indicatorType: Indicator.semiCircleSpin,
            ),
          ))
        : SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 60.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 20.0),
                            child: _imageUser == null
                                ? Image.asset(
                                    'assets/photouser_default.jpeg',
                                    height: 70.0,
                                    width: 77.0,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: 70,
                                        height: 70,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        imageUrl: _imageUser),
                                  ),
                          ),
                        ),
                        Text(_nameUser,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    TextFormField(
                      enabled: false,
                      controller: TextEditingController(text: _emailUser),
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                        hintText: '',
                        hintStyle:
                            TextStyle(height: 2, fontWeight: FontWeight.bold),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            height: 1,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black),
                      ),
                    ),
                    TextFormField(
                      maxLines: 2,
                      enabled: false,
                      controller: TextEditingController(
                          text: _homeUser == null ? 'no data' : _homeUser),
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        hintText: '',
                        hintStyle:
                            TextStyle(height: 2, fontWeight: FontWeight.bold),
                        labelText: 'Home Address',
                        labelStyle: TextStyle(
                            height: 1,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black),
                      ),
                    ),
                    TextFormField(
                      maxLines: 2,
                      enabled: false,
                      controller: TextEditingController(
                          text: _homeUser == null ? 'no data' : _homeUser),
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        hintText: '',
                        hintStyle:
                            TextStyle(height: 2, fontWeight: FontWeight.bold),
                        labelText: 'Temporary Address',
                        labelStyle: TextStyle(
                            height: 1,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black),
                      ),
                    ),
                    TextFormField(
                      maxLines: 2,
                      enabled: false,
                      controller: TextEditingController(
                          text: _officeUser == null ? 'no data' : _officeUser),
                      style: TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        hintText: '',
                        hintStyle:
                            TextStyle(height: 2, fontWeight: FontWeight.bold),
                        labelText: 'Office Address',
                        labelStyle: TextStyle(
                            height: 1,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      child: RoundedLoadingButton(
                        color: kBtnColor,
                        successColor: kBtnColor,
                        child:
                            Text('EDIT', style: TextStyle(color: Colors.white)),
                        controller: _btnController,
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditSettingScreen(),
                            ),
                          ).then(
                            (value) {
                              _read();
                            },
                          );
                          _btnController.reset();
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15.0, bottom: 25),
                      child: RoundedLoadingButton(
                        color: Colors.red,
                        child: Text('LOG OUT',
                            style: TextStyle(color: Colors.white)),
                        controller: _btnController1,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              backgroundColor: Colors.orange[50],
                              title: new Text('Are you sure?'),
                              content: new Text('Do you want to log out'),
                              actions: <Widget>[
                                new FlatButton(
                                  onPressed: () {
                                    _btnController1.reset();
                                    Navigator.of(context).pop();
                                  },
                                  child: new Text('No'),
                                ),
                                new FlatButton(
                                  onPressed: () {
                                    onLogout();
                                    _apiService
                                        .postLogout(_token)
                                        .then((result) {
                                      var dataJson = json.decode(result);
                                      if (dataJson['status'] == 200 ||
                                          Platform.isIOS) {
                                        _btnController.reset();
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/LoginScreen',
                                            ModalRoute.withName(
                                                '/LoginScreen'));
                                      } else {
                                        Navigator.pop(context, true);
                                        _btnController.reset();
                                      }
                                    });
                                  },
                                  child: new Text(
                                    'Yes',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'Version 7.0.9 (18.8.21)',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ))
                  ],
                ),
              ),
            ),
          );
  }

  _delete() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    final rowsDeleted = await helper.delete(rowId);
    print('deleted $rowsDeleted row(s): row $rowId');
  }

  Future<void> onLogout() async {
    print('logout in processing..');
    logindata = await SharedPreferences.getInstance();
    //imagetocheckou
    String? imageCheckin = logindata.getString('imageCheckin');
    bool? isCheckin = logindata.getBool('isCheckin');
    String? timeCheckin = logindata.getString('timeCheckin');
    String? timeExpired = logindata.getString('timeExpired');
    int? projectId = logindata.getInt('projectId');
    logindata.clear();
    logindata.setBool('isCheckin', isCheckin!);
    logindata.setString('imageCheckin', imageCheckin!);
    logindata.setString('timeCheckin', timeCheckin!);
    logindata.setString('timeExpired', timeExpired!);
    logindata.setInt('projectId', projectId!);
    await _delete();
  }
}
