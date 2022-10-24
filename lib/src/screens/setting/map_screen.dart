import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:attendance_app/src/utils/widget/loading/loader.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'dart:io' show Platform;

const kGoogleApiKeyAndro =
    "AIzaSyAIatYtSea_CIDxO6GmPydUtS5HcDTLaF0"; // API Keynya harus masukin billing dulu biar bisa dipakai lagi
const kGoogleApiKeyIos = "AIzaSyBmxTFFzKdfzTUORj36o4e3V50WXKpvMOE";
GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos);

class MapsScreen extends StatefulWidget {
  final String toUpdate;
  MapsScreen({required this.toUpdate});
  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  // Set<Marker> _markers = HashSet<Marker>();
  bool isMarker = false;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  int _markerIdCounter = 0;
  late String addresspositon = "";
  double? addlat;
  double? addlong;
  late SharedPreferences logindata;
  geo.Position? _currentPosition;
  loc.Location locationGps = loc.Location();
  // final LatLng _center = const LatLng(-6.177104698517575, 106.81901272521043);

  List<PlacesSearchResult> places = [];
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkGps();
  }

  Future _checkGps() async {
    logindata = await SharedPreferences.getInstance();
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        print("location denied");
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return PopDialog(
                  title: 'Location permission disabled',
                  content: 'You have to allow the location to access the map',
                  isWarning: false,
                  isButton: true,
                  onpressed: () async {
                    permission = await geo.Geolocator.requestPermission();
                    Navigator.pop(context);
                  });
            });
      }
    }
    await _getCurrentLocation();
  }

  _getCurrentLocation() {
    print("getCurrenttLocation");
    geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((geo.Position position) async {
      await GetAddressFromLatLong(position);
      setState(() {
        // addresspositon =
        //     GetAddressFromLatLong(position.latitude, position.longitude)
        //         as String;
        _currentPosition = position;
        addlat = position.latitude;
        addlong = position.longitude;
      });
      print("addlong : $addlong");
      print("Current position: $_currentPosition");
      print("addllat : $addlat");
      print("addressposition : $addresspositon");
    }).catchError((e) {
      print("error $e");
    });
    // geo.Geolocator.getCurrentPosition(
    //         desiredAccuracy: geo.LocationAccuracy.best,
    //         forceAndroidLocationManager: true)
    //     .then((geo.Position position) async {
    //   await onstartadd(position);
    //   // if (mounted) {
    //   setState(() {
    //     _currentPosition = position;
    //     addlat = position.latitude;
    //     addlong = position.longitude;
    //   });
    //   // }
    // }).catchError((e) {
    //   print(e);
    // });
  }

  Future onstartadd(double lat, long) async {
    // final coordinates = new Coordinates(position.latitude, position.longitude);
    print("waiting get data from coordinates");
    var addresses = await Geocoder2.getDataFromCoordinates(
        latitude: lat,
        longitude: long,
        googleMapApiKey:
            Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos);

    var firstt = addresses.address;

    setState(() {
      addresspositon = firstt;
    });
  }

  GetAddressFromLatLong(geo.Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print("Placemark : $placemarks}");
    Placemark place = placemarks[0];
    var Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      addresspositon = Address;
    });
  }

  String _markerIdVal({bool increment = false}) {
    String val = 'marker_id_$_markerIdCounter';
    if (increment) _markerIdCounter++;
    return val;
  }

  void _setMarkers(LatLng point) async {
    // final coordinates = new Coordinates(point.latitude, point.longitude);
    var addresses = await Geocoder2.getDataFromCoordinates(
        latitude: point.latitude,
        longitude: point.longitude,
        googleMapApiKey:
            Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos);
    var firstt = addresses.address;
    if (mounted) {
      MarkerId markerId = MarkerId(_markerIdVal());
      Marker marker = Marker(
        markerId: markerId,
        position: point,
        draggable: false,
        infoWindow: InfoWindow(title: addresspositon),
        visible: true,
      );
      setState(() {
        addresspositon = firstt;
        print("Latitude : ${point.latitude}");
        addlat = point.latitude;
        addlong = point.longitude;
        _markers[markerId] = marker;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (mounted) {
      MarkerId markerId = MarkerId(_markerIdVal());
      Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        draggable: false,
      );
      setState(() {
        _markers[markerId] = marker;
      });
    }
  }

  Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
    GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(p.placeId!);
    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    LatLng pointlatlong = LatLng(lat, lng);
    // final coordinates = new Coordinates(lat, lng);
    // var addresses = await Geocoder2.getDataFromCoordinates(
    //     latitude: lat,
    //     longitude: lng,
    //     googleMapApiKey:
    //         Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos);
    // var firstt = addresses.address;
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    print("Placemark : $placemarks}");
    Placemark place = placemarks[0];
    var Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      addresspositon = Address;
      addlat = lat;
      addlong = lng;
      _markers.clear();
      _setMarkers(pointlatlong);
      mapController.moveCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
    });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState!.showSnackBar(
      SnackBar(content: Text(response.errorMessage.toString())),
    );
  }

  getLoc(lat, long) async {
    // final coordinates = new Coordinates(lat, long);
    // var addresses = await Geocoder2.getDataFromCoordinates(
    //     latitude: lat,
    //     longitude: long,
    //     googleMapApiKey:
    //         Platform.isAndroid ? kGoogleApiKeyAndro : kGoogleApiKeyIos);
    // var firstt = addresses;
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    print("Placemark : $placemarks}");
    Placemark place = placemarks[0];
    var Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      addlat = lat;
      addlong = long;
      addresspositon = Address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        title: Text('Set ${widget.toUpdate} address location',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.orange,
      ),
      body: _currentPosition == null
          ? Loader()
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    zoom: 18,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: Set<Marker>.of(_markers.values),
                  myLocationEnabled: true,
                  onTap: (point) {
                    setState(() {
                      _markers.clear();
                      _setMarkers(point);
                    });
                  },
                  onCameraMove: (CameraPosition position) {
                    if (_markers.length > 0) {
                      MarkerId markerId = MarkerId(_markerIdVal());
                      Marker? marker = _markers[markerId];
                      Marker updatedMarker = marker!.copyWith(
                        positionParam: position.target,
                      );
                      getLoc(
                          position.target.latitude, position.target.longitude);
                      setState(() {
                        _markers[markerId] = updatedMarker;
                      });
                    }
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () async {
                      Prediction? p = await PlacesAutocomplete.show(
                          offset: 0,
                          // radius: 1000,
                          strictbounds: false,
                          onError: onError,
                          region: "id",
                          language: "en",
                          context: context,
                          mode: Mode.overlay,
                          types: ["(cities)"],
                          components: [Component(Component.country, "id")],
                          // startText: "",
                          apiKey: Platform.isAndroid
                              ? kGoogleApiKeyAndro
                              : kGoogleApiKeyIos);
                      displayPrediction(p!, homeScaffoldKey.currentState!);
                    },
                    child: Container(
                      width: 340.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.green)),
                      margin: EdgeInsets.only(top: 10.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 10.0),
                      child: Text(
                        addresspositon,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                // Align(
                //     // alignment: Alignment.center,
                //     child: Container(
                //         alignment: Alignment.centerRight,
                //         child: RaisedButton(
                //           onPressed: () async {
                //             Prediction p = await PlacesAutocomplete.show(
                //                 context: context, apiKey: kGoogleApiKey);
                //             displayPrediction(p, homeScaffoldKey.currentState);
                //           },
                //           child: Text('Find address'),
                //         ))),
              ],
            ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 85.0),
        child: FloatingActionButton(
          onPressed: () async {
            // print("set address");
            // if (addlat != null) {
            //   await onstartadd(addlat!, addlong);
            // }

            print("Widget : ${widget.toUpdate}");
            if (widget.toUpdate == 'home') {
              logindata.setString('homeUpdate', addresspositon);
              logindata.setDouble('homeLat', addlat!);
              logindata.setDouble('homeLong', addlong!);

              print("homeUpdate : ${logindata.getString("homeUpdate")}");
              print("homelat : ${logindata.getDouble("homeLat")}");
              print("homelong : ${logindata.getDouble("homeLong")}");
            } else {
              logindata.setString('officeUpdate', addresspositon);
              logindata.setDouble('officeLat', addlat!);
              logindata.setDouble('officeLong', addlong!);
            }
            //
            // condition for temporary address
            //
            Navigator.pop(context, addresspositon);
          },
          backgroundColor: Colors.orange,
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
