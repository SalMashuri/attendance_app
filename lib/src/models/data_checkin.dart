import 'dart:convert';

class CheckIn {
  final int projectId;
  final String location;
  // File image;
  final String image;
  final String fbtoken;
  final Geolocation geolocation;
  late double lat;
  late double long;

  CheckIn(
      {required this.projectId,
      required this.location,
      required this.image,
      required this.fbtoken,
      required this.geolocation});

  factory CheckIn.fromJson(Map<String, dynamic> map) {
    return CheckIn(
        projectId: map["project_id"],
        location: map["location"],
        image: map["image"],
        fbtoken: map["firebase_token"],
        geolocation: Geolocation.fromJson(map["geolocation"]));
  }

  // factory CheckIn.fromJson(dynamic json) {
  //   return Tutorial(json['title'] as String, json['description'] as String, User.fromJson(json['author']));
  // }

  Map<String, dynamic> toJson() {
    return {
      "project_id": projectId,
      "location": location,
      "image": image,
      "firebase_token": fbtoken,
      "geolocation": geolocation
    };
  }

  @override
  String toString() {
    // return "{project_id: $projectId, location: $location, image: $image, firebase_token: $fbtoken, geolocation: $geolocation}";
    return "{project_id: $projectId, location: $location, firebase_token: $fbtoken, geolocation: $geolocation}";
  }
}

class Geolocation {
  double lat;
  double long;

  Geolocation({required this.lat, required this.long});

  factory Geolocation.fromJson(Map<String, dynamic> json) {
    return Geolocation(
      lat: json["lat"],
      long: json["long"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "lat": lat,
      "long": long,
    };
  }

  @override
  String toString() {
    return "{lat: $lat, long: $long}";
  }
}

List<CheckIn> checkInFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<CheckIn>.from(data.map((item) => CheckIn.fromJson(item)));
}

String checkInToJson(CheckIn data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
