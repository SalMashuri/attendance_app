import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/db/database.dart';
import 'package:attendance_app/src/models/data_editprofile.dart';
import 'package:attendance_app/src/screens/setting/map_screen.dart';
import 'package:attendance_app/src/screens/setting/widgets/edit_image.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/services/relogin.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;

class AddLatLongg {
  double lat;
  double long;

  AddLatLongg(this.lat, this.long);

  factory AddLatLongg.fromJson(dynamic json) {
    return AddLatLongg(json['lat'] as double, json['long'] as double);
  }

  @override
  String toString() {
    return '{ ${this.lat}, ${this.long} }';
  }
}

// final String baseUrl = "https://attendance.msg.co.id";

class EditSettingScreen extends StatefulWidget {
  @override
  _EditSettingScreenState createState() => _EditSettingScreenState();
}

class _EditSettingScreenState extends State<EditSettingScreen> {
  ApiService _apiService = ApiService();
  loc.Location locationGps = loc.Location();
  late String _currentAddress;
  late SharedPreferences logindata;
  late String? token;
  late double? _homelat;
  late double? _homelong;
  late String? homeUser;
  late double? _officelat;
  late double? _officelong;
  late String? officeUser;
  Datauser? _data;
  late List datahomelatlong;
  late List dataofficelatlong;
  late String username;
  late String useremail;
  TextEditingController _controllerHome = TextEditingController();
  TextEditingController _controllerOffice = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();
  File? imageResized;
  String? filePath;
  File? _image;
  late String _imageuploaded;
  bool isLoadimage = false;
  String? _namee;
  late String? _emaill;
  bool isUpdatingAddress = false;

  @override
  void initState() {
    _namee = "";
    _emaill = "";
    _homelat = 0;
    _homelong = 0;
    super.initState();
    _read();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerHome.dispose();
    _controllerOffice.dispose();
  }

  _read() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    Datauser? datauser = await helper.queryDatauser(rowId);
    if (datauser != null) {
      if (!mounted) return;
      setState(() {
        _namee = datauser.name;
        _emaill = datauser.email;
        _data = datauser;
        _imageuploaded = datauser.image!;
        _data!.homeLatlong == null
            ? datahomelatlong = []
            : datahomelatlong = _data!.homeLatlong!.split(",");
        _data!.officeLatlong == null
            ? dataofficelatlong = []
            : dataofficelatlong = _data!.officeLatlong!.split(",");
        _data!.officeAddress != null && _data!.homeAddress != null
            ? isUpdatingAddress = true
            : isUpdatingAddress = false;
      });
    }
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      token = logindata.getString('token');
      homeUser = logindata.getString('homeUpdate')!;
      if (logindata.getDouble('homeLat') != null) {
        _homelat = logindata.getDouble('homeLat')!;
      }
      _homelong = logindata.getDouble('homeLong') ?? 0;
      officeUser = logindata.getString('officeUpdate') ?? "";
      _officelat = logindata.getDouble('officeLat') ?? 0;
      _officelong = logindata.getDouble('officeLong') ?? 0;
      _controllerHome.text = logindata.getString('homeUpdate') ?? 'no data';
      _controllerOffice.text = logindata.getString('officeUpdate') ?? 'no data';
    });
  }

  void _updateData() async {
    Datauser _dataa = Datauser(
        id: 1,
        name: _data!.name,
        email: _data!.email,
        status: _data!.status,
        homeAddress: homeUser,
        homeLatlong: _homelat != null
            ? Geolocationadd(lat: _homelat!, long: _homelong!).toString()
            : _data!.homeLatlong,
        officeAddress: officeUser,
        officeLatlong: _officelat != null
            ? Geolocationadd(lat: _officelat!, long: _officelong!).toString()
            : _data!.officeLatlong,
        image:
            _imageuploaded != null ? _imageuploaded.toString() : _data!.image,
        token: _data!.token);
    final helper = DatabaseHelper.instance;
    int? count = await helper.update(_dataa);
    print('updated $count row(s)');
    logindata.setDouble('homeLat', 0);
    logindata.setDouble('homeLong', 0);
    logindata.setDouble('officeLat', 0);
    logindata.setDouble('officeLong', 0);
  }

  Future uploadImage() async {
    File imageToUpload = await getImage();
    final base64Image = base64Encode(imageToUpload.readAsBytesSync());
    final imagetoupload = 'data:image/png;base64,' + base64Image;
    setState(() => isLoadimage = true);
    await _apiService.uploadImage(imagetoupload, token!).then((value) {
      if (value == 'timeout') {
        if (!mounted) return;
        setState(() => isLoadimage = false);
        onTimeout();
      } else {
        var jsondata = json.decode(value);
        var statusCode = jsondata['status'];
        var imagepath = jsondata['full_path_image'];
        if (statusCode == 200) {
          logindata.setString('imageToedit', imageToUpload.path.toString());
          logindata.setString('imageUrl', imagepath);
          if (!mounted) return;
          setState(() {
            _image = imageToUpload;
            _imageuploaded = imagepath;
            isLoadimage = false;
          });
          _updateData();
        }
      }
    });
  }

  Future getImage() async {
    XFile? imagee;
    try {
      imagee = await ImagePicker.platform.getImage(
          source: ImageSource.gallery,
          maxHeight: 1024,
          maxWidth: 1024,
          imageQuality: 100);
      if (!mounted) return;
      if (imagee == null) {
        return;
      }
      return imagee;
    } catch (error) {
      print('error taking picture ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: kAppBarColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
              onPressed: () => Navigator.pop(context)),
          centerTitle: true,
          title: const Text(
            'Edit Data',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    _image == null && isLoadimage == false
                        ? EditImageContainer(
                            icon: Icon(
                              Icons.camera_enhance,
                              size: 50,
                            ),
                            onpressed: () => uploadImage(),
                          )
                        : isLoadimage == true
                            ? Container(
                                width: 120,
                                height: 120,
                                padding: EdgeInsets.all(5),
                                child: LoadingIndicator(
                                  backgroundColor: Colors.orange,
                                  indicatorType: Indicator.semiCircleSpin,
                                ),
                              )
                            : EditImageContainer(
                                icon: ClipRRect(
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    width: 140,
                                    height: 140,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.camera_enhance,
                                      size: 50,
                                    ),
                                    imageUrl: _imageuploaded,
                                  ),
                                ),
                                onpressed: () => getImage(),
                              ),
                    Text(_namee ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                TextFormField(
                  enabled: false,
                  controller: TextEditingController(text: _emaill ?? ""),
                  style: TextStyle(color: Colors.grey),
                  decoration: kTextFieldEditDecor.copyWith(labelText: 'Email'),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        maxLines: 2,
                        enabled: false,
                        controller: _controllerHome,
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            homeUser = value;
                          });
                        },
                        style: TextStyle(color: Colors.grey),
                        decoration: kTextFieldEditDecor.copyWith(
                            labelText: 'Home Address'),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          var resultPage = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapsScreen(
                                toUpdate: 'home',
                              ),
                            ),
                          );
                          if (resultPage != null) {
                            _read();
                          }
                          _btnController.reset();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 41.0),
                          color: Colors.orange,
                          child: Text(
                            'search',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        maxLines: 2,
                        enabled: false,
                        controller: _controllerHome,
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            homeUser = value;
                          });
                        },
                        style: TextStyle(color: Colors.grey),
                        decoration: kTextFieldEditDecor.copyWith(
                            labelText: 'Temporary Address'),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          var resultPage = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapsScreen(
                                toUpdate: 'home',
                              ),
                            ),
                          );
                          if (resultPage != null) {
                            _read();
                          }
                          _btnController.reset();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 41.0),
                          color: Colors.orange,
                          child: Text(
                            'search',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        maxLines: 2,
                        enabled: false,
                        controller: _controllerOffice,
                        onChanged: (value) {
                          setState(() {
                            officeUser = value;
                          });
                        },
                        style: TextStyle(color: Colors.grey),
                        decoration: kTextFieldEditDecor.copyWith(
                            labelText: 'Office Address'),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async {
                          var resultPage = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapsScreen(
                                toUpdate: 'office',
                              ),
                            ),
                          );
                          if (resultPage != null) {
                            _read();
                          }
                          _btnController.reset();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 41.0),
                          color: Colors.orange,
                          child: Text(
                            'search',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: submitButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget submitButton() {
    return Builder(
      builder: (context) => RoundedLoadingButton(
        color: new Color(0xFFff7f00),
        successColor: new Color(0xFFff7f00),
        child: Text('SAVE', style: TextStyle(color: Colors.white)),
        controller: _btnController,
        onPressed: () async {
          var _editaddress = await loadData();
          _apiService
              .editAddress(_editaddress, token!, isUpdatingAddress)
              .then((result) {
            if (result == 'timeout') {
              _btnController.reset();
              onTimeout();
            } else {
              var jsondata = json.decode(result);
              // print(jsondata);
              var statusCode = jsondata['status'];
              var message = jsondata['message'];
              if (statusCode == 200) {
                // isUpdatingAddress == true ? onSuccess(message) : _updateData();
                _btnController.success();
                // to update the address in edit and setting screen
                _updateData();
                // to inform the user that needed the boss approval
                onSuccess(message);
              } else if (statusCode == 401) {
                _btnController.reset();
                onReLogin(jsondata);
              } else {
                _btnController.reset();
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

  onFailed(jsondata) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to update your data',
            content: 'Please try again',
            isWarning: true,
            warningText: jsondata['message'],
            isButton: false,
          );
        });
  }

  onSuccess(message) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
              title: 'Your data successfully change',
              content: message,
              isWarning: false,
              isButton: true,
              onpressed: () {
                _btnController.reset();
                Navigator.pop(context);
                Navigator.pop(context, _imageuploaded);
              },
            ),
          );
        });
  }

  loadData() {
    var hlat = datahomelatlong[0].split(" ");
    var hlong = datahomelatlong[1].trim().split(" ");
    var olat = dataofficelatlong[0].split(" ");
    var olong = dataofficelatlong[1].trim().split(" ");
    Geolocationadd geolocationOffice = Geolocationadd(
      lat: _officelat ?? double.parse(olat[1].trim()),
      long: _officelong ?? double.parse(olong[1].trim().replaceAll('}', '')),
    );
    Geolocationadd geolocationHome = Geolocationadd(
      lat: _homelat ?? double.parse(hlat[1].trim()),
      long: _homelong ?? double.parse(hlong[1].trim().replaceAll('}', '')),
    );
    EditAddress editaddress = EditAddress(
      officeAddress: officeUser ?? _currentAddress.toString(),
      officeLatlong: geolocationOffice,
      homeAddress: homeUser ?? _currentAddress.toString(),
      homeLatlong: geolocationHome,
      workShift: 2,
    );
    return editaddress;
  }

  onTimeout() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Connection Failed',
            content:
                'There is no response on server or please check your connectivity',
            isWarning: false,
            isButton: true,
            onpressed: () => Navigator.pop(context),
          );
        });
  }
}
