import 'package:flutter/material.dart';

class TitleField extends StatelessWidget {
  TitleField({required this.textfield, this.fontweight});
  final String textfield;
  FontWeight? fontweight;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        textfield,
        style: TextStyle(
          fontSize: 17,
          fontWeight: fontweight,
        ),
      ),
    );
  }
}
