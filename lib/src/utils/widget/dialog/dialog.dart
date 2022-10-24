import 'package:flutter/material.dart';

class PopDialog extends StatelessWidget {
  final String title;
  final String? content;
  final bool? isWarning;
  final String? warningText;
  final bool? isTask;
  final void Function()? onTaskYes;
  final void Function()? onTaskNo;
  final bool isButton;
  final void Function()? onpressed;

  PopDialog({
    required this.title,
    this.content,
    required this.isWarning,
    this.warningText,
    this.isTask,
    this.onTaskYes,
    this.onTaskNo,
    required this.isButton,
    this.onpressed,
  });

  // onWillPop: () async => false,
  // onpressed: () => Navigator.pop(context),
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.orange[50],
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // content != null
          //     ? Container(
          //         margin: EdgeInsets.only(bottom: 10.0),
          //         child: Text(
          //           content,
          //           style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 17.0,
          //           ),
          //           textAlign: TextAlign.center,
          //         ),
          //       )
          //     : Container(),
          content != null
              ? Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    content!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(),
          isTask == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: ButtonTheme(
                        buttonColor: Color(0xFFff7f00),
                        child: RaisedButton(
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          onPressed: onTaskYes,
                          child: Text(
                            'YES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: ButtonTheme(
                        buttonColor: Color(0xFFff7f00),
                        child: RaisedButton(
                          textColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          onPressed: onTaskNo!,
                          child: Text(
                            'NO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          isWarning == true
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    warningText!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(),
          isButton == true
              ? Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: ButtonTheme(
                    buttonColor: Color(0xFFff7f00),
                    child: RaisedButton(
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      onPressed: onpressed,
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      // actions: [],
    );
  }
}

// AlertDialog(
//   backgroundColor: Colors.orange[50],
//   title: Text("Session Timeout",
//       textAlign: TextAlign.center),
//   content: Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         'Please check your connectivity',
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 18.0,
//         ),
//         textAlign: TextAlign.center,
//       ),
//       Padding(
//         padding: const EdgeInsets.only(top: 15.0),
//         child: ButtonTheme(
//           buttonColor: new Color(0xFFff7f00),
//           child: RaisedButton(
//             textColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(5.0),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: new Text(
//               'OKE',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.0,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

// class DialogAlert extends StatefulWidget {
//   @override
//   _DialogAlertState createState() => _DialogAlertState();
// }

// class _DialogAlertState extends State<DialogAlert> {
//   @override
//   Widget build(BuildContext context) {
//     return showDialog();
//   }
// }
