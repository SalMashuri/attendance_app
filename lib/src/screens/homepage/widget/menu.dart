import 'package:flutter/material.dart';

class MenuContainer extends StatelessWidget {
  MenuContainer(
      {this.icon, this.onpressed, this.title, this.index, this.absencetext});
  final Image? icon;
  final void Function()? onpressed;
  final String? title;
  final int? index;
  final String? absencetext;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 170.0,
      width: 120,
      height: 200.0,
      margin: EdgeInsets.symmetric(horizontal: 30),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10.0,
            offset: Offset(0.0, 12.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              child:
                  IconButton(icon: icon!, iconSize: 100, onPressed: onpressed)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              index == 1
                  ? Text(
                      absencetext!,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrangeAccent),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
