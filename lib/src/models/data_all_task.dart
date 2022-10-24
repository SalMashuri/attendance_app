import 'dart:convert';

class AllTask {
  final int id;
  final String title;
  final String startTime;
  final String endTime;
  final String type;
  final String note;
  final String report;
  final String createdDate;
  final List<String> reportFile;

  AllTask(
      {required this.id,
      required this.title,
      required this.startTime,
      required this.endTime,
      required this.type,
      required this.note,
      required this.report,
      required this.createdDate,
      required this.reportFile});

  @override
  String toString() {
    return "{id: $id, title: $title, start_time: $startTime, end_time: $endTime, type: $type, note: $note, report: $report, crate_date: $createdDate, report_file: $reportFile}";
  }

  factory AllTask.fromJson(Map<String, dynamic> json) {
    return AllTask(
        id: json["id"],
        title: json["title"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        type: json["type"],
        note: json["note"],
        report: json["report"],
        createdDate: json["created_date"],
        reportFile: List<String>.from(json['report_file']));
  }
}

List<AllTask> historyFromJson(dynamic jsonData) {
  final data = json.decode(jsonData);
  return List<AllTask>.from(data.map((item) => AllTask.fromJson(item)));
}
