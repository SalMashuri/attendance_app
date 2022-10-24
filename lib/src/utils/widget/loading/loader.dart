import 'package:flutter/material.dart';
import 'package:loading_indicator/src/loading.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.orange,
        height: 75,
        width: 75,
        child: LoadingIndicator(
          backgroundColor: Colors.white,
          indicatorType: Indicator.semiCircleSpin,
        ),
      ),
    );
  }
}
