import 'package:flutter/material.dart';

class ExitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
            backgroundColor: Colors.orange[50],
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: new Text(
                  'Yes',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
  }
}