import 'package:attendance_app/src/screens/task/widgets/title_field.dart';
import 'package:flutter/material.dart';

class DateTimeField extends StatelessWidget {
  final title;
  final VoidCallback onSelected;
  final String text;
  final Icon icon;
  final int flexcontainer;
  DateTimeField(
      {required this.title,
      required this.text,
      required this.onSelected,
      required this.icon,
      required this.flexcontainer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TitleField(
              textfield: title,
            ),
          ),
          Expanded(
            flex: flexcontainer,
            child: Container(
              height: 45.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: FlatButton(
                padding: EdgeInsets.all(10),
                onPressed: onSelected,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14.0)),
                    icon
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );

    // return Expanded(
    //   flex: flexcontainer,
    //   child: Container(
    //     height: 45.0,
    //     decoration: BoxDecoration(
    //       color: Colors.grey[300],
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     child: FlatButton(
    //       padding: EdgeInsets.all(10),
    //       onPressed: onSelected,
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Text(text,
    //               textAlign: TextAlign.center,
    //               style:
    //                   TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
    //           icon
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
