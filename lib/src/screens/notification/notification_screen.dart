import 'package:attendance_app/src/utils/const/constant.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isNotif = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isNotif == false
        ? Container(
            child: Text('There is no pending data'),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              toolbarHeight: 70,
              backgroundColor: kAppBarColor,
              leading: IconButton(
                icon: kBackButton,
                onPressed: () {
                  Navigator.pop(context, '/HomePage');
                },
              ),
              centerTitle: true,
              title: const Text(
                'Approval Notification',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Text('user'),
                SizedBox(
                  height: 10,
                ),
                Text('Requesting to change the address below :'),
                SizedBox(
                  height: 10,
                ),
                Text('Old home address:'),
                Text('MSG'),
                SizedBox(
                  height: 10,
                ),
                Text('New home address:'),
                Text('MSG 1'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Deny'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Approve'),
                    )
                  ],
                )
              ],
            )));
  }
}
