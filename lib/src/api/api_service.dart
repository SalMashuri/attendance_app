import 'package:attendance_app/src/models/data_checkin.dart';
import 'package:attendance_app/src/models/data_create_task.dart';
import 'package:attendance_app/src/models/data_editprofile.dart';
import 'package:attendance_app/src/models/data_login.dart';
import 'package:attendance_app/src/models/data_report.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' show Client;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:async';

class ApiService {
  static String baseUrl = "https://attendance.msg.co.id";
  // static String baseUrl = "http://116.213.55.119";
  // static String baseUrl = "https://attendance.zarkasih.my.id";

  Client client = Client();

  Future getDashboard(String token) async {
    print('loading dashboard..');
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        // "content-type": "application/json",
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("$baseUrl/api/v1/dashboard");
      var request = new http.MultipartRequest("GET", uri);
      request.headers.addAll(headers);
      var response = await request.send().timeout(const Duration(seconds: 20));
      var responseData = await response.stream.toBytes();
      var dataresult = String.fromCharCodes(responseData);
      if (response.statusCode == 200) {
        return dataresult;
      }
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future uploadImage(String imagee, String token) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "content-type": "application/json",
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("${baseUrl}/api/v1/change_profile_image");
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["image"] = imagee.toString();
      var response = await request.send().timeout(const Duration(seconds: 20));
      var responseData = await response.stream.toBytes();
      var dataresult = String.fromCharCodes(responseData);
      if (response.statusCode == 200) {
        return dataresult;
      }
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  postTokenFirebase(String token, String fbtoken) async {
    print("sending firebase token");
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "content-type": "application/json",
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("$baseUrl/api/v1/firebase");
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["firebase_token"] = fbtoken;
      var response = await request.send();
      final completer = Completer<String>();
      final contents = StringBuffer();
      response.stream.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));
      return completer.future;
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future postLoginData(DataLogin data) async {
    print('login in Progress..');
    try {
      var uri = Uri.parse("$baseUrl/api/v1/login");
      var request = new http.MultipartRequest("POST", uri);
      request.fields["email"] = data.email;
      request.fields["password"] = data.password;
      var response = await request.send().timeout(const Duration(seconds: 15));
      print(response.statusCode);
      var responseData = await response.stream.toBytes();
      var dataresult = String.fromCharCodes(responseData);
      if (response.statusCode == 200) {
        return dataresult;
      }
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future postLogout(String token) async {
    try {
      var uri = Uri.parse("$baseUrl/api/v1/logout");
      var request = new http.MultipartRequest("POST", uri);
      request.fields["token"] = token;
      var response = await request.send().timeout(const Duration(seconds: 20));
      final completer = Completer<String>();
      final contents = StringBuffer();
      response.stream.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));
      return completer.future;
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future postCheckIn(CheckIn data, String token) async {
    print('CheckIn in Progress..');
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "content-type": "application/json",
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("${baseUrl}/api/v1/attendance/signin");
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["project_id"] = data.projectId.toString();
      request.fields["location"] = data.location;
      request.fields["geolocation"] = data.geolocation.toString();
      request.fields["image"] = data.image;
      request.fields["firebase_token"] = data.fbtoken;
      var response = await request.send().timeout(const Duration(seconds: 20));
      // final dataresult =
      //     response.stream.transform(utf8.decoder).listen((value) {});
      // if (response.statusCode == 200) {
      //   return dataresult;
      // }
      final completer = Completer<String>();
      final contents = StringBuffer();
      response.stream.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));
      return completer.future;
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future postCheckOut(CheckIn data, String token) async {
    print('checkout processing..');
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("${baseUrl}/api/v1/attendance/signout");
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["project_id"] = data.projectId.toString();
      request.fields["location"] = data.location;
      request.fields["geolocation"] = data.geolocation.toString();
      // request.fields["image"] = data.image;
      var response = await request.send().timeout(const Duration(seconds: 20));
      final completer = Completer<String>();
      final contents = StringBuffer();
      response.stream.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));
      return completer.future;
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future<String> createTask(DataTask data, String token) async {
    print('create task processing..');
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("${baseUrl}/api/v1/task");
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["title"] = data.title;
      request.fields["start_time"] = data.startTime;
      request.fields["end_time"] = data.endTime;
      request.fields["type"] = data.type;
      request.fields["note"] = data.note;
      request.fields["location"] = data.location;
      request.fields["geolocation"] = data.geolocation.toString();
      var response = await request.send().timeout(const Duration(seconds: 20));
      final completer = Completer<String>();
      final contents = StringBuffer();
      response.stream.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));
      return completer.future;
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err.toString();
    }
  }

  Future createReport(DataReport data, String token) async {
    print('create report processing..');
    print(data);
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("${baseUrl}/api/v1/task/report");
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["task_id"] = data.taskId.toString();
      request.fields["report"] = data.report;
      for (int i = 0; i < data.filereports.length; i++) {
        request.files.add(
          http.MultipartFile(
            'filereports[$i]',
            http.ByteStream(
                DelegatingStream.typed(data.filereports[i].openRead())),
            await data.filereports[i].length(),
            filename: basename(data.filereports[i].path),
          ),
        );
      }
      var response = await request.send().timeout(const Duration(seconds: 15));
      final completer = Completer<String>();
      final contents = StringBuffer();
      response.stream.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));
      return completer.future;
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future getListTask(String token) async {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "content-type": "application/json",
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      // final response = await http
      //     .get("$baseUrl/api/v1/task", headers: headers)
      //     .timeout(const Duration(seconds: 20));
      // if (response.statusCode == 200) {
      //   return response;
      // }
      var uri = Uri.parse("${baseUrl}/api/v1/task");
      var request = new http.MultipartRequest("GET", uri);
      request.headers.addAll(headers);
      var response = await request.send().timeout(const Duration(seconds: 20));
      print(response.statusCode);
      var responseData = await response.stream.toBytes();
      var dataresult = String.fromCharCodes(responseData);
      if (response.statusCode == 200) {
        return dataresult;
      }
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }

  Future editAddress(
      EditAddress data, String token, bool isUpdatingAddress) async {
    String apiAddress;
    print('edit data in Progress..');
    isUpdatingAddress == true
        ? apiAddress = 'api/v1/address/update'
        : apiAddress = 'api/v1/address';
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);
    String gen = "${token}MSG${formattedDate}";
    Digest signatureData = md5.convert(utf8.encode(gen));
    String signature = signatureData.toString();
    try {
      final Map<String, String> headers = {
        "content-type": "application/json",
        "token": token,
        "signature": signature,
        "timestamp": formattedDate
      };
      var uri = Uri.parse("$baseUrl/$apiAddress");
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["home_address"] = data.homeAddress;
      request.fields["office_address"] = data.officeAddress;
      request.fields["working_shift"] = data.workShift.toString();
      request.fields["home_latlong"] = data.homeLatlong.toString();
      request.fields["office_latlong"] = data.officeLatlong.toString();
      var response = await request.send().timeout(const Duration(seconds: 15));
      print(response.statusCode);
      var responseData = await response.stream.toBytes();
      var dataresult = String.fromCharCodes(responseData);
      if (response.statusCode == 200) {
        return dataresult;
      }
    } on TimeoutException catch (_) {
      return 'timeout';
    } catch (err) {
      print('Caught error: $err');
      return err;
    }
  }
}
