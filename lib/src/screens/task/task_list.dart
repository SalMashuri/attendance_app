import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/models/data_all_task.dart';
import 'package:attendance_app/src/screens/task/report.dart';
import 'package:attendance_app/src/screens/task/task_create.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:attendance_app/src/utils/widget/loading/loader.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' show Client;

class ListTaskScreen extends StatefulWidget {
  @override
  _ListTaskScreenState createState() => _ListTaskScreenState();
}

class _ListTaskScreenState extends State<ListTaskScreen> {
  late SharedPreferences logindata;
  late String token;
  Client client = Client();
  ApiService _apiService = ApiService();
  // final String baseUrl = "https://attendance.msg.co.id";
  List<AllTask>? dataList;
  bool checkedValue = false;
  String? nodata;

  @override
  void initState() {
    super.initState();
    _initial();
  }

  void _initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      token = logindata.getString('token')!;
    });
    print('token $token');
    await _getlist();
  }

  onTimeOut() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
              title: 'Load data failed',
              content: 'Please check your connectivity',
              isWarning: false,
              isButton: true,
              onpressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              });
        });
  }

  _getlist() async {
    _apiService.getListTask(token).then((result) {
      if (result == 'timeout') {
        onTimeOut();
      } else {
        var jsondata = json.decode(result);
        var statusCode = jsondata['code'];
        if (statusCode == '200') {
          List data = jsondata['data'];
          setState(() {
            data != null
                ? dataList = data
                    .map((dataList) => new AllTask.fromJson(dataList))
                    .toList()
                : dataList = [];
          });
        } else {
          setState(() => dataList = []);
        }
      }
    });
  }

  // _getlist() async {
  //   var getList = await _apiService.getListTask(token);
  //   if (getList == 'timeout') {
  //     onTimeOut();
  //   } else {
  //     var jsonn = json.decode(getList);
  //     var statusCode = jsonn['code'];
  //     if (statusCode == '200') {
  //       List data = jsonn['data'];
  //       setState(() {
  //         data != null
  //             ? dataList = data
  //                 .map((dataList) => new AllTask.fromJson(dataList))
  //                 .toList()
  //             : dataList = [];
  //       });
  //     } else if (statusCode == '401') {
  //       print('you have to re-login');
  //     } else {
  //       return;
  //     }
  //   }
  // }

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
            }),
        centerTitle: true,
        title: const Text(
          'Task List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: dataList == null
          ? Loader()
          : dataList!.isNotEmpty
              ? WillPopScope(
                  onWillPop: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/HomePage', (Route<dynamic> route) => false);
                    return Future.value(false);
                  },
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: dataList == null ? 0 : dataList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: index == 0
                              ? EdgeInsets.only(
                                  top: 15, bottom: 7, left: 15, right: 15)
                              : EdgeInsets.symmetric(
                                  vertical: 7.0, horizontal: 15.0),
                          color: (index % 2 == 0)
                              ? Colors.grey[350]
                              : Colors.grey[200],
                          child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (_) {
                                    return ReportDetailScreen(
                                        datatask: dataList![index]);
                                  },
                                  settings: RouteSettings(
                                    name: '/ReportDetailScreen',
                                  ),
                                ))
                                    .then((val) {
                                  setState(() {
                                    dataList = dataList == dataList
                                        ? dataList
                                        : dataList;
                                  });
                                });
                              },
                              child: _tile(dataList![index])),
                        );
                      },
                    ),
                  ),
                )
              : Center(
                  child: Text('there is no data yet'),
                ),
      floatingActionButton: Container(
        width: 65.0,
        height: 65.0,
        child: new RawMaterialButton(
          fillColor: Colors.orange,
          shape: new CircleBorder(),
          elevation: 2.0,
          child: Container(
              width: 65.0,
              child: Icon(
                Icons.add,
                size: 30,
                color: Colors.white,
              )),
          onPressed: () async {
            // Navigator.pushNamed(context, '/CreateTask');
            var resultPage = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateTask(),
              ),
            );
            if (resultPage != null) {
              _initial();
            }
          },
        ),
      ),
    );
  }

  ListTile _tile(AllTask list) {
    return ListTile(
        title: Text(
          list.createdDate,
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          list.title,
          maxLines: 1,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_right));
  }
}
