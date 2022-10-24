import 'package:flutter/material.dart';

class TaksScreen extends StatefulWidget {
  const TaksScreen({Key? key}) : super(key: key);

  @override
  State<TaksScreen> createState() => _TaksScreenState();
}

class _TaksScreenState extends State<TaksScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Task Screen"),
    );
  }
}
