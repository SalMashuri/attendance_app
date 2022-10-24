import 'package:attendance_app/src/screens/notification/notification_screen.dart';
import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:flutter/material.dart';

class NotificationTimelineScreen extends StatefulWidget {
  @override
  _NotificationTimelineScreenState createState() =>
      _NotificationTimelineScreenState();
}

class _NotificationTimelineScreenState
    extends State<NotificationTimelineScreen> {
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
              // Navigator.of(context).pushNamedAndRemoveUntil(
              //     '/HomePage', (Route<dynamic> route) => false);
            }),
        centerTitle: true,
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/HomePage', (Route<dynamic> route) => false);
          return Future.value(false);
        },
        child: Scrollbar(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
            color: Colors.grey[350],
            child: GestureDetector(
                onTap: () {
                  print('go to notification screen');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                },
                child: _tile()),
          ),
        ),
      ),
    );
  }

  ListTile _tile() {
    return ListTile(
        title: Text(
          'test',
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        subtitle: Text(
          'test',
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
