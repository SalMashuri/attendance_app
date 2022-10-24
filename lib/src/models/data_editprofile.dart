import 'dart:convert';

class EditAddress {
  Geolocationadd officeLatlong;
  String officeAddress;
  String homeAddress;
  Geolocationadd homeLatlong;
  late double lat;
  late double long;
  int workShift;

  EditAddress(
      {required this.officeAddress,
      required this.officeLatlong,
      required this.homeAddress,
      required this.homeLatlong,
      required this.workShift});

  factory EditAddress.fromJson(Map<String, dynamic> map) {
    return EditAddress(
      officeAddress: map["office_address"],
      officeLatlong: Geolocationadd.fromJson(map["office_latlong"]),
      homeAddress: map["home_address"],
      homeLatlong: Geolocationadd.fromJson(map["home_latlong"]),
      workShift: map["working_shift"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "office_address": officeAddress,
      "office_latlong": officeLatlong,
      "home_address": homeAddress,
      "home_latlong": homeLatlong,
      "working_shift": workShift
    };
  }

  @override
  String toString() {
    return "{office_address: $officeAddress, office_latlong: $officeLatlong, home_address: $homeAddress, home_latlong: $homeLatlong, working_shift: $workShift}";
    // return "{office_address: $officeAddress, office_latlong: {$officeLatlong}, home_address: $homeAddress, home_latlong: {$homeLatlong}, working_shift: $workShift}";
  }
}

class Geolocationadd {
  double lat;
  double long;

  Geolocationadd({required this.lat, required this.long});

  factory Geolocationadd.fromJson(Map<String, dynamic> json) {
    return Geolocationadd(
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
    return "{lat: ${lat}, long: ${long}}";
    // return "lat: $lat, long: $long";
  }
}

List<EditAddress> addressFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<EditAddress>.from(data.map((item) => EditAddress.fromJson(item)));
}

String addressToJson(EditAddress data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
