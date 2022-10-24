import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionLoc {
  Future<bool> checkGpsIos() async {
    var status = await Permission.location.request();
    if (status.isDenied || status.isRestricted) {
      return false;
    }
    return true;
    // _getCurrentLocation();
  }

  Future checkGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled == false) {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => WarningPage(
        //       page: 'AbsenceScreen',
        //     ),
        //   ),
        // );
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            // return showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return PopupDialog.locPermissionDisabled(
            //           onPressedOk: () async {
            //         permission = await Geolocator.requestPermission();
            //         Navigator.pop(context);
            //       });
            //     });
          }
        }
        getCurrentLocation();
      }
    } catch (e) {
      print('error');
    }
  }

  Future<Position> getCurrentLocation() async {
    var yaya;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      yaya = position;
    }).catchError((e) {
      print(e);
      return null;
    });
    return yaya;
  }

  getAddressFromLatLng(Position position) async {
    try {
      print("Posisition task lat : ${position.latitude}");
      // final coordinates =
      // new Coordinates(position.latitude, position.longitude);
      var addresses = await Geocoder2.getDataFromCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          googleMapApiKey: "AIzaSyAkQvERngjE-BhEZpfuSgvAQpyPWPst-7g");
      // await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var address = addresses.address;
      var addrss = address;
      print("get LOcation : $addrss");
      return addrss;
    } catch (e) {
      print(e);
    }
  }
}

// _getCurrentLocation() {
  //   Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //       .then((Position position) {
  //     if (mounted) {
  //       if (position != null) {
  //         setState(() {
  //           _currentPosition = position;
  //         });
  //       } else if (Platform.isIOS) {
  //         return showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return PopupDialog.locDisabled();
  //             });
  //       }
  //     }
  //     _getAddressFromLatLng();
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  // _getAddressFromLatLng() async {
  //   try {
  //     final coordinates = new Coordinates(
  //         _currentPosition.latitude, _currentPosition.longitude);
  //     var addresses =
  //         await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //     var address = addresses.first;
  //     if (mounted) {
  //       setState(() {
  //         _latPositon = _currentPosition.latitude;
  //         _longPositon = _currentPosition.longitude;
  //         _currentAddress = "${address.addressLine}";
  //       });
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }