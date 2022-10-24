import 'package:flutter/material.dart';

class EditImageContainer extends StatelessWidget {
  final Function()? onpressed;
  final Widget icon;
  EditImageContainer({
    required this.icon,
    this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      width: 140,
      height: 140,
      child: IconButton(
        icon: icon,
        iconSize: 50,
        onPressed: onpressed,
      ),
    );
  }
}
