import 'package:attendance_app/src/screens/absence/checkin.dart';
import 'package:attendance_app/src/screens/absence/checkout.dart';
import 'package:attendance_app/src/screens/warning/warning.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/services/location.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:attendance_app/src/utils/widget/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;

enum Absence { checkin, checkout }

class AbsenceScreen extends StatefulWidget {
  final Absence absenceText;
  AbsenceScreen({required this.absenceText});
  @override
  _AbsenceScreenState createState() => _AbsenceScreenState();
}

class _AbsenceScreenState extends State<AbsenceScreen> {
  int? _character;
  XFile? _image;
  late String filePath;
  late String photoBase64;
  late String imageBase64;
  PermissionLoc _permissionloc = PermissionLoc();
  loc.Location locationGps = loc.Location();
  late Position _currentPosition;
  String _currentAddress = "";
  double _latPositon = 00;
  double _longPositon = 00;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  late SharedPreferences logindata;
  late bool isCheckin;
  late String token;
  late String _fbtoken;
  late File imagetoCheckout;
  late bool _isContainerVisible = false;
  late int _projectId;
  late String _text;

  @override
  void initState() {
    super.initState();
    print('in absence text: ${widget.absenceText}');
    Platform.isIOS ? _checkGpsios() : _checkGps();
    startTime();
    initial();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _checkGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WarningPage(
              page: 'AbsenceScreen',
            ),
          ),
        );
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          bool status = await Permission.locationWhenInUse.isDenied;
          // permission = await Geolocator.requestPermission();
          if (status) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PopDialog(
                      title: 'Location permission disabled',
                      content:
                          'You have to allow the location access to check in',
                      isWarning: false,
                      isButton: true,
                      onpressed: () async {
                        permission = await Geolocator.requestPermission();
                        Navigator.pop(context, 'checkin');
                      });
                });
          }
        }
        getLocation();
      }
    } catch (e) {
      print('error');
    }
  }

  Future _checkGpsios() async {
    bool isPermissionLoc = await _permissionloc.checkGpsIos();
    if (isPermissionLoc == false) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopDialog(
                title: 'Location Disabled',
                content: 'You have to allow the location access to check in',
                isWarning: false,
                isButton: true,
                onpressed: () async {
                  await Geolocator.openLocationSettings();
                  Navigator.pop(context, 'checkin');
                });
          });
    } else
      getLocation();
  }

  locDisabled() {
    return PopDialog(
      title: 'Location Disabled',
      content: 'You have to allow the location access to check out',
      isWarning: false,
      isButton: false,
    );
  }

  getLocation() async {
    Position isGetLocation = await _permissionloc.getCurrentLocation();
    if (isGetLocation == null) {
      if (Platform.isIOS) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return locDisabled();
            });
      }
    } else {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          isGetLocation.latitude, isGetLocation.longitude);
      print("Placemark : $placemarks}");
      Placemark place = placemarks[0];
      var Address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      // var addrss = await _permissionloc.getAddressFromLatLng(isGetLocation);
      setState(() {
        _currentAddress = Address;
        _latPositon = isGetLocation.latitude;
        _longPositon = isGetLocation.longitude;
      });
    }
  }

  Future<void> initial() async {
    logindata = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        token = logindata.getString('token')!;
        _fbtoken = logindata.getString('fbtoken')!;
        isCheckin = logindata.getBool('isCheckin') == null
            ? false
            : logindata.getBool('isCheckin')!;
        // _character = logindata.getInt('projectId')!;
        widget.absenceText == Absence.checkin
            ? _text = 'Check in'
            : _text = 'Check Out';
      });
    }
  }

  _showWarning() {
    if (mounted) {
      setState(() => _isContainerVisible = true);
    }
  }

  startTime() async {
    var duration = Duration(seconds: 15);
    return Timer(duration, _showWarning);
  }

  failedLoadLoc({void Function()? onPressedOk}) {
    return PopDialog(
      title: 'Failed to load your location',
      content: 'Please try again',
      isWarning: false,
      isButton: true,
      onpressed: () {
        Navigator.popUntil(
          context,
          ModalRoute.withName('/HomePage'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: kAppBarColor,
        leading: IconButton(
          icon: kBackButton,
          onPressed: () {
            Navigator.pop(context, 'checkin');
          },
        ),
        centerTitle: true,
        title: const Text(
          'Absence',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _latPositon == null && _longPositon == null
          ? _isContainerVisible == false
              ? Loader()
              : WillPopScope(
                  onWillPop: () async => false,
                  child: failedLoadLoc(),
                )
          : widget.absenceText == Absence.checkin
              ? Checkin(
                  lat: _latPositon,
                  long: _longPositon,
                  address: _currentAddress,
                )
              : Checkout(
                  lat: _latPositon,
                  long: _longPositon,
                  address: _currentAddress,
                ),
    );
  }
}
