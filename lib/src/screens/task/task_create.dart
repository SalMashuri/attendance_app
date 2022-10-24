import 'dart:io';

import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/models/data_checkin.dart';
import 'package:attendance_app/src/models/data_create_task.dart';
import 'package:attendance_app/src/screens/task/widgets/date_field.dart';
import 'package:attendance_app/src/screens/task/widgets/date_time_field.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/services/location.dart';
import 'package:attendance_app/src/utils/services/relogin.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:attendance_app/src/utils/widget/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class CreateTask extends StatefulWidget {
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  ApiService _apiService = ApiService();
  PermissionLoc _permissionloc = PermissionLoc();
  late SharedPreferences logindata;
  late String token;
  late String _currentAddress;
  double _latPositon = 0.0;
  double _longPositon = 0.0;
  late TimeOfDay timestart;
  late TimeOfDay timeend;
  late String timeStartText = '';
  late String timeEndText = '';
  late String dataTugas;
  // late String dataketerangan;
  late String dataJudul;
  TextEditingController _controllerJudul = TextEditingController();
  TextEditingController _controllerKeterangan = TextEditingController();
  late String dataKeterangan;
  String? _valTugas;
  List _listTugas = [
    {"id": "1", "text": "Project"},
    {"id": "2", "text": "Client"},
    {"id": "3", "text": "Rutin"}
  ];
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  DateTime? selectedTimein;
  late String timeIn;
  DateTime? selectedTimeout;
  late String timeOut;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      token = logindata.getString('token')!;
    });
    getLocation();
  }

  getLocation() async {
    Position isGetLocation = await _permissionloc.getCurrentLocation();
    print('task geo: $isGetLocation');
    if (isGetLocation == null) {
      if (Platform.isIOS) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return locDisabled();
            });
      }
    } else {
      print("is get location : $isGetLocation");
      String addrss = await _permissionloc.getAddressFromLatLng(isGetLocation);
      print("adrss : $addrss");
      setState(() {
        _latPositon = isGetLocation.latitude;
        _longPositon = isGetLocation.longitude;
        _currentAddress = addrss;
      });
    }
  }

  locDisabled() {
    return PopDialog(
      title: 'Location Disabled',
      content: 'You have to allow the location access to check out',
      isWarning: false,
      isButton: false,
    );
  }

  void _setTime(int index) async {
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: index == 2 ? selectedTimein : DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        index == 1 ? selectedTimein = date : selectedTimeout = date;
        index == 1
            ? timeIn = DateFormat('kk:mm').format(date)
            : timeOut = DateFormat('kk:mm').format(date);
      });
    },
        currentTime: selectedTimein != null ? selectedTimein : DateTime.now(),
        locale: LocaleType.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: kAppBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/HomePage', (Route<dynamic> route) => false);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Create New Task',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: WillPopScope(
          onWillPop: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/ListTask', (Route<dynamic> route) => false);
            return Future.value(false);
          },
          child: _latPositon == null
              ? Center(child: Loader())
              : SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        DateTimeField(
                          title: 'Start',
                          text: selectedTimein == null
                              ? ''
                              : "${selectedTimein!.toLocal()}".split(' ')[0] +
                                  '     |     ' +
                                  timeIn,
                          onSelected: () => _setTime(1),
                          icon: Icon(Icons.date_range),
                          flexcontainer: 2,
                        ),
                        DateTimeField(
                          title: 'End',
                          text: selectedTimeout == null
                              ? ''
                              : "${selectedTimeout!.toLocal()}".split(' ')[0] +
                                  '     |     ' +
                                  timeOut,
                          onSelected: () => _setTime(2),
                          icon: Icon(Icons.date_range),
                          flexcontainer: 2,
                        ),
                        Column(
                          children: [
                            DataField(
                              idField: 1,
                              title: 'Title',
                              onchanged: (text) {
                                setState(() => dataJudul = text);
                              },
                            ),
                            DataField(
                              idField: 4,
                              title: 'Assignment',
                              valtugas: _valTugas,
                              listtugas: _listTugas,
                              controller: _controllerJudul,
                              onchanged: (value) {
                                print("value vall tugaas : $value");
                                // setState(() => _valTugas = value);
                              },
                            ),
                            DataField(
                              idField: 3,
                              title: 'Details',
                              controller: _controllerKeterangan,
                              onchanged: (text) {
                                setState(() => dataKeterangan = text);
                              },
                            ),
                            buttonSubmit(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget buttonSubmit() {
    return Builder(
      builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: RoundedLoadingButton(
            color: kBtnColor,
            successColor: kBtnColor,
            child: Text('SUBMIT', style: TextStyle(color: Colors.white)),
            controller: _btnController,
            onPressed: () async {
              if (selectedTimein == null ||
                  selectedTimeout == null ||
                  dataJudul == null ||
                  _valTugas == null ||
                  dataKeterangan == null) {
                _btnController.reset();
                emptyData();
              } else {
                var dataTask = await datatoTask();
                print(dataTask);
                _apiService.createTask(dataTask, token).then((result) {
                  if (result == 'timeout') {
                    _btnController.reset();
                    onTimeout();
                  } else {
                    var dataJson = json.decode(result);
                    var statusCode = dataJson['status'];
                    if (statusCode == "success") {
                      onSuccess();
                      _btnController.reset();
                    } else if (statusCode == 401) {
                      _btnController.reset();
                      onReLogin(dataJson);
                    } else {
                      onFailed(dataJson);
                      _btnController.reset();
                    }
                  }
                });
              }
            },
          )),
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
                  await ReLogin().onLogout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/LoginScreen', (Route<dynamic> route) => false);
                }),
          );
        });
  }

  emptyData() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to recorded the task',
            content: 'Please fill the data correctly',
            isWarning: false,
            isButton: false,
          );
        });
  }

  datatoTask() {
    Geolocation geolocation = Geolocation(lat: _latPositon, long: _longPositon);
    DataTask dataTask = DataTask(
        title: dataJudul,
        startTime: selectedTimein.toString(),
        endTime: selectedTimeout.toString(),
        type: _valTugas ?? "",
        note: dataKeterangan,
        location: _currentAddress,
        geolocation: geolocation);

    return dataTask;
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
                  'There is no response on server or please check your connectivity',
              isWarning: false,
              isButton: true,
              onpressed: () => Navigator.pop(context),
            ),
          );
        });
  }

  onSuccess() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
              title: 'Successfully recorded the task',
              content: 'Do you want to input another task ?',
              isWarning: false,
              isButton: false,
              isTask: true,
              onTaskYes: () {
                setState(() {
                  _controllerKeterangan.clear();
                  _controllerJudul.clear();
                  timeStartText = '';
                  timeEndText = '';
                  _valTugas = "";
                  Navigator.of(context).pop();
                });
              },
              onTaskNo: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/ListTask', (Route<dynamic> route) => false);
              },
            ),
          );
        });
  }

  onFailed(dataJson) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
              title: 'Failed to recorded the task',
              content: 'Please try again',
              isWarning: true,
              warningText: dataJson['message'],
              isButton: true,
              onpressed: () => Navigator.pop(context),
            ),
          );
        });
  }
}
