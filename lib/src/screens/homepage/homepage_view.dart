import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:badges/badges.dart';
import 'package:attendance_app/src/screens/absence/absence.dart';
import 'package:attendance_app/src/screens/homepage/widget/indicator.dart';
import 'package:attendance_app/src/screens/homepage/widget/menu.dart';
import 'package:attendance_app/src/screens/notification/notificationtimeline_screen.dart';
import 'package:attendance_app/src/screens/task/task_create.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/models/data_dashboard.dart';
import 'package:attendance_app/src/screens/homepage/widget/pie_chart.dart';
import 'package:attendance_app/src/screens/task/task_list.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/services/relogin.dart';
import 'package:attendance_app/src/utils/widget/loading/loader.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ApiService _apiService = ApiService();
  PieChartSection _pieChartSection = PieChartSection();
  ReLogin _relogin = ReLogin();
  late SharedPreferences logindata;
  bool? _isCheckin;
  DateTime? _timeToexpired;
  String? _timeExpired;
  String? textAbsence;
  String? _name;
  String? urlImage;
  String? _token;
  int? touchedIndex;
  String? lastCheckin;
  List? _listworkloc = [];
  List? _workloc = [];
  bool? _load = true;
  int? sumworklist;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadSignature() {
    final DateTime now = DateTime.now();
    final String datee = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${_token}MSG${datee}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    print('token $_token');
    print('timestamp: $datee');
    print('signature: $signature');
  }

  Future _loadDashboard() async {
    _apiService.getDashboard(_token!).then((result) {
      if (result != null) {
        var jsondata = json.decode(result);
        print(jsondata);
        var statusCode = jsondata['status'];
        // print("status code : " + statusCode);
        if (statusCode == 401) {
          // if (Platform.isAndroid) {
          onReLogin(jsondata);
          // } else {
          //   setState(() {
          //     lastCheckin = '-';
          //     _listworkloc = [];
          //     _load = false;
          //     sumworklist = 0;
          //     _workloc = [];
          //   });
          // }
        } else {
          var dataWorklocation = jsondata['data']['work_location'];
          var _list = [];
          dataWorklocation.forEach((k, v) => _list.add(WorkLocation(k, v)));
          setState(() {
            lastCheckin = jsondata['data']['last_check_in'];
            _listworkloc = _list;
            _load = false;
          });
          var data = _listworkloc!
              .where((oldValue) => '0' != (oldValue.workval.toString()));
          setState(() {
            sumworklist = data.length;
          });
          for (var i = 0; i < _listworkloc!.length; i++) {
            if (_listworkloc![i].workval == 0) {
            } else {
              setState(() {
                _workloc!.add(int.parse(_listworkloc![i].workkey));
              });
            }
          }
        }
      }
    });
    await _loadSignature();
    await _loadTextAbsence();
  }

  _loadUserInfo() async {
    logindata = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (mounted) {
      setState(() {
        _name = logindata.getString('name');
        // urlImage = logindata.getString('imageUrl');
        logindata.getString('imageUrl') ==
                "https://attendance.msg.co.id/backend/uploads/images/user-default.jpg"
            ? urlImage = null
            : urlImage = logindata.getString('imageUrl');
        // "https://attendance.msg.co.id/backend/uploads/images/user-default.jpg"
        _isCheckin = logindata.getBool('isCheckin');
        _timeExpired = logindata.getString('timeExpired');
        _token = logindata.getString('token');
      });
      print('token: $_token');
    }
    await _loadDashboard();
  }

  _loadTextAbsence() async {
    DateTime timeNow = DateTime.now();
    if (_timeExpired != null) {
      setState(() {
        _timeToexpired = DateTime.parse(_timeExpired!);
      });
      if (timeNow.isBefore(_timeToexpired!) && _isCheckin == true) {
        setState(() {
          textAbsence = 'Check Out';
        });
      } else {
        logindata.setBool('isCheckin', false);
        setState(() {
          textAbsence = 'Check In';
          _isCheckin = logindata.getBool('isCheckin');
        });
      }
    } else {
      setState(() {
        _timeToexpired = timeNow;
        textAbsence = 'Check In';
      });
    }
  }

  _gotoAbsence() async {
    DateTime _time = DateTime.now();
    if (_isCheckin == true && _time.isBefore(_timeToexpired!)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AbsenceScreen(
            absenceText: Absence.checkout,
          ),
        ),
      ).then(
        (value) {
          _loadTextAbsence();
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AbsenceScreen(
            absenceText: Absence.checkin,
          ),
        ),
      );
    }
  }

  _gotoTask() async {
    var resultPage = await Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (context) => CreateTask(),
        builder: (context) => ListTaskScreen(),
      ),
    );
    if (resultPage != null) {
      _loadUserInfo();
    }
  }

  // _gotoNotification() async {
  //   var resultPage = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => NotificationScreen(),
  //     ),
  //   );
  //   if (resultPage != null) {
  //     _loadUserInfo();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kAppBarColor,
      child: Column(
        children: [
          Container(
            color: kAppBarColor,
            height: 150,
            padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  // child: urlImage !=
                  //             "https://attendance.msg.co.id/backend/uploads/images/user-default.jpg" ||
                  //         urlImage != null
                  child: urlImage != null
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          imageUrl: urlImage!)
                      : Image.asset(
                          'assets/photouser_default.jpeg',
                          height: 70.0,
                          width: 77.0,
                        ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 30.0),
                  child: Text(_name ?? '',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          _load == true
              ? Center(child: Loader())
              : Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 35.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: SingleChildScrollView(
                      child: Container(
                        // height: 585,
                        height: 830,
                        child: Column(
                          children: [
                            Stack(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  height: 65,
                                  margin: EdgeInsets.fromLTRB(20, 10, 20, 30),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                        color: Colors.orange,
                                      )),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    child: Text(
                                      lastCheckin!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 17.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    left: 40,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      color: Colors.white,
                                      child: Text(
                                        'Last Login',
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                    )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 165.0,
                                    width: 165.0,
                                    child: PieChart(
                                      PieChartData(
                                          startDegreeOffset: 180,
                                          borderData: FlBorderData(
                                            show: false,
                                          ),
                                          sectionsSpace: 7,
                                          centerSpaceRadius: 5,
                                          sections:
                                              _pieChartSection.showingSections(
                                                  _workloc, _listworkloc)),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Indicator(
                                          color: Colors.orangeAccent[700],
                                          text: 'WFO',
                                        ),
                                        Indicator(
                                          color: Colors.lightGreen,
                                          text: 'WFH',
                                        ),
                                        Indicator(
                                          color: Colors.blue,
                                          text: 'WFC',
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MenuContainer(
                                    icon: Image.asset('assets/absence.png'),
                                    onpressed: () => _gotoAbsence(),
                                    title: 'Absence ',
                                    index: 1,
                                    absencetext:
                                        textAbsence != null ? textAbsence : '',
                                  ),
                                  MenuContainer(
                                    icon: Image.asset('assets/Report.png'),
                                    onpressed: () => _gotoTask(),
                                    title: 'Task',
                                    index: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
        ],
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
                title: 'Failed to check in',
                content: jsondata['message'],
                isWarning: false,
                isButton: true,
                onpressed: () async {
                  await _relogin.onLogout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/LoginScreen', (Route<dynamic> route) => false);
                }),
          );
        });
  }
}
