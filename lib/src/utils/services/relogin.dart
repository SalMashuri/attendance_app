import 'package:attendance_app/src/db/database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReLogin {
  late SharedPreferences logindata;

  Future delete() async {
    print('deletng all data..');
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    final rowsDeleted = await helper.delete(rowId);
    print('deleted $rowsDeleted row(s): row $rowId');
  }

  Future onLogout() async {
    print('logout in processing..');
    logindata = await SharedPreferences.getInstance();
    //imagetocheckou
    String? imageCheckin = logindata.getString('imageCheckin');
    bool? isCheckin = logindata.getBool('isCheckin');
    String? timeCheckin = logindata.getString('timeCheckin');
    String? timeExpired = logindata.getString('timeExpired');
    int? projectId = logindata.getInt('projectId');
    logindata.clear();
    logindata.setBool('isCheckin', isCheckin!);
    logindata.setString('imageCheckin', imageCheckin!);
    logindata.setString('timeCheckin', timeCheckin!);
    logindata.setString('timeExpired', timeExpired!);
    logindata.setInt('projectId', projectId!);
    await delete();
  }
}
