import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/models/data_all_task.dart';
import 'package:attendance_app/src/models/data_report.dart';
import 'package:attendance_app/src/screens/task/widgets/report_data_field.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/services/relogin.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:loading_indicator/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDetailScreen extends StatefulWidget {
  final AllTask datatask;
  ReportDetailScreen({required this.datatask});

  @override
  _ReportDetailScreenState createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  TextEditingController _controllerLaporan = TextEditingController();
  ApiService _apiService = ApiService();
  late SharedPreferences logindata;
  late String token;
  late String dataLaporan;
  List<String>? filexisted;
  List<File> _reportFiles = <File>[];
  String? filefile;
  List<PlatformFile>? _paths;
  List<PlatformFile> _filespath = [];
  bool _loadingPath = false;
  bool isWarningFile = false;

  @override
  void initState() {
    super.initState();
    if (widget.datatask.report != null) {
      _controllerLaporan.text = widget.datatask.report;
    }
    if (widget.datatask.reportFile.isNotEmpty) {
      setState(() {
        filexisted = widget.datatask.reportFile;
      });
    }
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      token = logindata.getString('token')!;
    });
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    if (_paths != null && _paths!.isNotEmpty) {
      setState(() {
        for (var element in _paths!) {
          _filespath.add(element);
        }
      });
    } else {
      _filespath = [];
    }
    setState(() {
      _loadingPath = false;
    });
  }

  double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  checkFileSize() {
    List thesize = [];
    thesize = _filespath.map((e) => e.size / (1024 * 1024)).toList();
    double sum = 0;
    for (var i = 0; i < thesize.length; i++) {
      sum += dp(thesize[i], 2);
    }
    if (sum > 9.5) {
      return false;
    } else {
      return true;
    }
  }

  _launchURL(String linkurl) async {
    final url = linkurl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: const Text(
          'Report',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: widget.datatask == null
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
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ReportDataField(
                            text1: 'Start',
                            text2:
                                '${widget.datatask.startTime.split(' ')[0]}   |   ${widget.datatask.startTime.split(' ')[1]}',
                          ),
                          ReportDataField(
                            text1: 'End',
                            text2:
                                '${widget.datatask.endTime.split(' ')[0]}   |   ${widget.datatask.endTime.split(' ')[1]}',
                          ),
                          ReportDataField(
                            text1: 'Title',
                            text2: widget.datatask.title,
                          ),
                          ReportDataField(
                            text1: 'Assigment',
                            text2: widget.datatask.type,
                          ),
                          ReportDataField(
                            text1: 'Details',
                            text2: widget.datatask.note == null ||
                                    widget.datatask.note == ''
                                ? " - "
                                : widget.datatask.note,
                          ),
                          Divider(
                            thickness: 1.5,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15),
                            child: Container(
                              child: Text(
                                'Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 10.0, right: 15, left: 15),
                            height: 100.0,
                            width: 325.0,
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: TextFormField(
                              enabled: true,
                              maxLines: 3,
                              controller: _controllerLaporan,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              ),
                              onChanged: (text) {
                                setState(() {
                                  dataLaporan = text;
                                });
                              },
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 5.0, bottom: 5),
                              padding: const EdgeInsets.all(15.0),
                              child: submitButton()),
                          isWarningFile == true
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 15.0),
                                  child: Text(
                                    'Error uploading report : Sorry, your file exceeds the Max. upload size (10 MB)',
                                    style: TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container(),
                          Divider(
                            thickness: 1.5,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            child: Text(
                              'Uploaded :',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.datatask.reportFile.isNotEmpty
                        ? ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.datatask.reportFile != null &&
                                    widget.datatask.reportFile.isNotEmpty
                                ? widget.datatask.reportFile.length
                                : 1,
                            itemBuilder: (BuildContext context, int index) {
                              final attached = widget.datatask.reportFile
                                  .map((e) => e)
                                  .toList()[index]
                                  .toString();
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 20.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _launchURL(attached);
                                  },
                                  child: Text(
                                    attached,
                                    style: TextStyle(color: Colors.blue[700]),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : Container(),
                    Divider(
                      thickness: 1.5,
                    ),
                    _loadingPath
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: const CircularProgressIndicator(),
                          )
                        : _filespath != null
                            ? ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _filespath.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String name =
                                      'File ${index + 1} :    ' +
                                          (_filespath
                                              .map((e) => e.name)
                                              .toList()[index]);
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isWarningFile = false;
                                                _filespath =
                                                    List.from(_filespath)
                                                      ..removeAt(index);
                                              });
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            name,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                              )
                            : Container(),
                    if (_filespath.isEmpty && _loadingPath == false)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          'click the icon to add attachment',
                          style: TextStyle(
                              color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    SizedBox(
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                Icons.note_add,
                size: 30,
                color: Colors.white,
              )),
          onPressed: () {
            _openFileExplorer();
          },
        ),
      ),
    );
  }

  submitButton() {
    return Builder(
      builder: (context) => RoundedLoadingButton(
        color: kBtnColor,
        successColor: kBtnColor,
        child: Text('SUBMIT', style: TextStyle(color: Colors.white)),
        controller: _btnController,
        onPressed: () async {
          var isOk = checkFileSize();
          if (isOk == true) {
            if (dataLaporan == null && _filespath.isEmpty ||
                dataLaporan == '' && _filespath.isEmpty ||
                dataLaporan == widget.datatask.report && _filespath.isEmpty) {
              noData();
              _btnController.reset();
            } else {
              var _datatoreport = await dataToReport();
              _apiService.createReport(_datatoreport, token).then((result) {
                if (result == 'timeout') {
                  _btnController.reset();
                  onTimeout();
                } else {
                  var jsondata = json.decode(result);
                  var statusCode = jsondata['status'];
                  if (statusCode == 'success') {
                    onSuccess();
                    _btnController.reset();
                  } else if (statusCode == 401) {
                    _btnController.reset();
                    onReLogin(jsondata);
                  } else {
                    _btnController.reset();
                    onFailed(jsondata);
                  }
                }
              });
            }
          } else {
            setState(() {
              isWarningFile = true;
              _btnController.reset();
            });
          }
        },
      ),
    );
  }

  noData() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Sorry, failed to recorded the report',
            content: 'There is no data to report',
            isWarning: false,
            isButton: false,
          );
        });
  }

  dataToReport() {
    if (_filespath != null && _filespath.isNotEmpty) {
      _filespath.map((e) => _reportFiles.add(File(e.path!))).toString();
    }
    widget.datatask.report != null && dataLaporan == null || dataLaporan == ''
        ? dataLaporan = widget.datatask.report
        : dataLaporan = dataLaporan;
    DataReport datatoreport = DataReport(
      taskId: widget.datatask.id,
      report: dataLaporan != null ? dataLaporan : '',
      filereports: _reportFiles,
    );
    return datatoreport;
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
              title: 'Successfully recorded the report',
              content: 'Thank you',
              isWarning: false,
              isButton: true,
              onpressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/ListTask');
              },
            ),
          );
        });
  }

  onFailed(jsondata) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to report the task',
            content: 'Please try again',
            isWarning: true,
            warningText: jsondata['message'],
            isButton: false,
          );
        });
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
}
