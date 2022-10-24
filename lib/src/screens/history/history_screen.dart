import 'package:attendance_app/src/models/data_history.dart';
import 'package:attendance_app/src/utils/services/relogin.dart';
import 'package:attendance_app/src/utils/widget/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' show Client;

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? token;
  late SharedPreferences logindata;
  final String baseUrl = "https://attendance.msg.co.id";
  // final String baseUrl = "http://116.213.55.119";
  // static String baseUrl = "https://attendance.zarkasih.my.id";

  Client client = Client();
  List<DataHistory>? _dataHistory;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      token = logindata.getString('token');
    });
    print('token $token');
    await getHistory(token!);
  }

  Future getHistory(String token) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "token": token,
      "signature": signature,
      "timestamp": formattedDate
    };
    print(headers);
    // final response = await client.get(
    //   Uri.https(baseUrl, "/api/v1/attendance"),
    //   headers: headers,
    // );
    final response = await client.get(Uri.parse("$baseUrl/api/v1/attendance"),
        headers: headers);
    if (response.statusCode == 200) {
      var jsonn = json.decode(response.body);
      if (jsonn['code'] == "200") {
        List data = jsonn['data'];
        setState(() {
          data != null
              ? _dataHistory = data
                  .map((datahistory) => new DataHistory.fromJson(datahistory))
                  .toList()
              : _dataHistory = [];
        });
      } else if (jsonn['status'] == 401) {
        // onReLogin(jsonn);
        setState(() => _dataHistory = []);
      } else {
        setState(() => _dataHistory = []);
        onFailed(jsonn);
      }
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  onFailed(jsonn) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            title: 'Failed to load data',
            content: jsonn['message'],
            isWarning: false,
            isButton: false,
          );
        });
  }

  onReLogin(jsondata) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: PopDialog(
                title: 'Failed to check in',
                content: jsondata['message'],
                isWarning: false,
                isButton: true,
                onpressed: () async {
                  await ReLogin().onLogout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/LoginScreen', (Route<dynamic> route) => false);
                }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return _dataHistory == null
        ? Center(
            child: Container(
            padding: EdgeInsets.all(20.0),
            color: Colors.orange,
            height: 75,
            width: 75,
            child: LoadingIndicator(
              backgroundColor: Colors.white,
              indicatorType: Indicator.semiCircleSpin,
            ),
          ))
        : _dataHistory!.isNotEmpty
            ? Scrollbar(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 75.0),
                  child: new ListView.builder(
                    itemCount: _dataHistory == null ? 0 : _dataHistory!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: _tile(
                          _dataHistory![index].date,
                          _dataHistory![index].summary,
                          _dataHistory![index].image,
                        ),
                      );
                    },
                  ),
                ),
              )
            : Center(
                child: Text('there is no data yet'),
              );
  }

  ListTile _tile(String date, String summary, String image) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: CachedNetworkImage(
            fit: BoxFit.cover,
            width: 55,
            height: 55,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            imageUrl: image),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                )),
          ),
        ],
      ),
      subtitle: Text(
        summary,
        maxLines: 1,
        style: TextStyle(color: Colors.black, fontSize: 14),
      ),
      // trailing: Icon(Icons.more_vert),
      // trailing: Text(
      //   'Lihat Task',
      //   style: TextStyle(color: Colors.orange, fontSize: 12),
      // ),
    );
  }
}
