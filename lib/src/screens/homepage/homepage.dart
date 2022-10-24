import 'dart:async';
import 'dart:io' show Platform;
import 'package:attendance_app/src/api/api_service.dart';
import 'package:attendance_app/src/db/database.dart';
import 'package:attendance_app/src/screens/history/history_screen.dart';
import 'package:attendance_app/src/screens/homepage/homepage_view.dart';
import 'package:attendance_app/src/screens/setting/setting_screen.dart';
import 'package:attendance_app/src/screens/warning/warning.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:attendance_app/src/utils/widget/dialog/exitapp_dialog.dart';
import 'package:attendance_app/src/utils/widget/loading/loader.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' show Client;
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      "this is the message notifification title: ${message.notification!.title}");
  print("this is the message data title: ${message.data['title']}");
  // print("this is the message type: ${message.messageType}");
  // print("this is the sender id: ${message.senderId}");
  // print("Handling a background message: ${message.messageId}");
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiService _apiService = ApiService();
  int _page = -1;
  GlobalKey _bottomNavigationKey = GlobalKey();
  Client client = Client();
  loc.Location locationGps = loc.Location();
  late SharedPreferences logindata;
  late String _fbtoken;
  String? _name;
  String? urlImage;
  int? sumWorkLoc;
  String? lastCheckin;
  String? messageTitle = "";
  String notificationAlert = "";
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // List _listworkloc = [];
  // String _token;

  @override
  void initState() {
    super.initState();
    registerNotification();
    _checkGps();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void registerNotification() async {
    logindata = await SharedPreferences.getInstance();

    // WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    late String tokenfcm;
    if (Platform.isAndroid) {
      tokenfcm = (await messaging.getToken())!;
      setState(() => _fbtoken = tokenfcm);
      logindata.setString('fbtoken', tokenfcm);
      print('fbtoken android adalah $_fbtoken');
    } else if (Platform.isIOS) {
      tokenfcm = (await messaging.getToken())!;
      setState(() => _fbtoken = tokenfcm);
      logindata.setString('fbtoken', tokenfcm);
      print('fbtoken ios adalah $_fbtoken');
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      setState(() {
        messageTitle = message.data['title'];
        print(message.data['title']);
        print(message.notification!.title);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        print('Message data: ${message.data}');
        print(message.data['title']);
        print(message.notification!.title);
      });
    });
  }

  Future _checkGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool serviceStatusResult = await locationGps.requestService();
      if (serviceStatusResult == false) {
        if (Platform.isAndroid) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WarningPage(
                page: 'HomePage',
              ),
            ),
          );
        }
      }
    }
    _loadUserInfo();
  }

  _loaduserDB() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    Datauser? datauser = await helper.queryDatauser(rowId);
    if (datauser == null) {
    } else {
      if (datauser.homeAddress == null && datauser.officeAddress == null) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return PopDialog(
                title: 'There is no address yet',
                content: 'Please update your address in settings menu first',
                isWarning: false,
                isButton: false,
              );
            });
      }
    }
  }

  _loadUserInfo() async {
    await _loaduserDB();
    logindata = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (mounted) {
      setState(() {
        _name = logindata.getString('name');
        urlImage = logindata.getString('imageUrl');
        // _token = logindata.getString('token');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _name == null && urlImage == null
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            body: Loader(),
          )
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              body: Stack(
                children: [
                  _getPageContent(_page),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CurvedNavigationBar(
                      animationCurve: Curves.easeOutCirc,
                      index: 1,
                      height: 67.0,
                      key: _bottomNavigationKey,
                      backgroundColor: Colors.transparent,
                      color: kBottomBarColor,
                      items: <Widget>[
                        Icon(Icons.history,
                            size: kBottomBarIconSize, color: kIconColor),
                        Icon(Icons.home,
                            size: kBottomBarIconSize, color: kIconColor),
                        Icon(Icons.settings,
                            size: kBottomBarIconSize, color: kIconColor),
                      ],
                      onTap: (index) {
                        if (index == 0) {
                          setState(() => _page = index);
                        } else if (index == 2) {
                          setState(() => _page = index);
                        } else
                          setState(() => _page = index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _getPageContent(int value) {
    switch (value) {
      case 0:
        return HistoryScreen();
        break;
      case 1:
        return HomeView();
        break;
      case 2:
        return SettingScreen();
      default:
        return HomeView();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
            context: context, builder: (context) => ExitApp())) ??
        false;
  }
}
