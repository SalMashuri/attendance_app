import 'dart:convert';

class DataHistory {
  final String title;
  final String summary;
  final int id;
  final String projectTitle;
  final String action;
  final String image;
  final String date;

  DataHistory(
      {required this.title,
      required this.summary,
      required this.id,
      required this.projectTitle,
      required this.action,
      required this.image,
      required this.date});

  @override
  String toString() {
    return "{title: $title, summary: $summary, id: $id, project_title: $projectTitle, action: $action, image: $image, date: $date}";
  }

  factory DataHistory.fromJson(Map<String, dynamic> json) {
    return DataHistory(
        title: json["title"],
        summary: json["summary"],
        id: json["id"],
        projectTitle: json["project_title"],
        action: json["action"],
        image: json["image"],
        date: json["date"]);
  }
}

List<DataHistory> historyFromJson(dynamic jsonData) {
  final data = json.decode(jsonData);
  return List<DataHistory>.from(data.map((item) => DataHistory.fromJson(item)));
}
