import 'package:attendance_app/src/screens/homepage/homepage.dart';
import 'package:attendance_app/src/screens/homepage/homepage_view.dart';
import 'package:attendance_app/src/screens/login/login_screen.dart';
import 'package:attendance_app/src/screens/splash/splash_screen.dart';
import 'package:attendance_app/src/screens/warning/warning.dart';
import 'package:attendance_app/src/screens/warning/warning_version.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: kAppBarColor, // status bar color
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MSG Attendance',
      routes: {
        '/': (context) => SplashScreen(),
        '/LoginScreen': (context) => LoginScreen(),
        '/WarningVersion': (context) => WarningVersion(),
        '/Warning': (context) => WarningPage(),
        '/HomePage': (context) => HomePage(),
        '/HomeView': (context) => HomeView(),
      },
      theme: ThemeData(
        buttonColor: Colors.orange,
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange,
        bottomAppBarColor: Colors.orange[100],
        appBarTheme: AppBarTheme(
          color: Colors.orange,
        ),
      ),
    );
  }
}
