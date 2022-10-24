import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:core';

class PieChartSection {
  List<PieChartSectionData> showingSections(data, listworkloc) {
    return List.generate(
      data.length,
      (i) {
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: data[i] == 1
                  ? Colors.orangeAccent[700]
                  : data[i] == 2
                      ? Colors.lightGreen
                      : Colors.blue,
              value: listworkloc[data[i] - 1].workval.toDouble(),
              title: listworkloc[data[i] - 1].workval.toString(),
              radius: 75,
              titleStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              // titlePositionPercentageOffset: 0.55,
            );
          case 1:
            return PieChartSectionData(
              color: data[i] == 1
                  ? Colors.orangeAccent[700]
                  : data[i] == 2
                      ? Colors.lightGreen
                      : Colors.blue,
              value: listworkloc[data[i] - 1].workval.toDouble(),
              title: listworkloc[data[i] - 1].workval.toString(),
              radius: 75,
              titleStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              // titlePositionPercentageOffset: 0.55,
            );
          case 2:
            return PieChartSectionData(
              color: data[i] == 1
                  ? Colors.orangeAccent[700]
                  : data[i] == 2
                      ? Colors.lightGreen
                      : Colors.blue,
              value: listworkloc[data[i] - 1].workval.toDouble(),
              title: listworkloc[data[i] - 1].workval.toString(),
              radius: 75,
              titleStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              // titlePositionPercentageOffset: 0.6,
            );
          default:
            return PieChartSectionData();
        }
      },
    );
  }
}
