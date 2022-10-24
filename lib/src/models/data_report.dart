import 'dart:convert';
import 'dart:io';

class DataReport {
  int taskId;
  String report;
  List<File> filereports;

  DataReport({
    required this.taskId,
    required this.report,
    required this.filereports,
  });

  factory DataReport.fromJson(Map<String, dynamic> map) {
    return DataReport(
        taskId: map["task_id"],
        report: map["report"],
        filereports: map["filereports"]);
  }

  Map<String, dynamic> toJson() {
    return {"task_id": taskId, "report": report, "filereports": filereports};
  }

  @override
  String toString() {
    return "{task_id: $taskId, report: $report, filereports: $filereports}";
  }
}

List<DataReport> reportFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<DataReport>.from(data.map((item) => DataReport.fromJson(item)));
}

String reportToJson(DataReport data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
