import 'dart:convert';

class DataAttendance {
  String status;
  int code;

  DataAttendance({required this.status, required this.code});

  factory DataAttendance.fromJson(Map<String, dynamic> map) {
    return DataAttendance(status: map["status"], code: map["code"]);
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "code": code};
  }

  @override
  String toString() {
    return "{status: $status, code: $code}";
  }
}

List<DataAttendance> attendanceFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<DataAttendance>.from(
      data.map((item) => DataAttendance.fromJson(item)));
}

String attendanceToJson(DataAttendance data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
