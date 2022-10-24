import 'dart:convert';

class DataSignature {
  String token;
  String timestamp;

  DataSignature({required this.token, required this.timestamp});

  factory DataSignature.fromJson(Map<String, dynamic> map) {
    return DataSignature(token: map["token"], timestamp: map["timestamp"]);
  }

  Map<String, dynamic> toJson() {
    return {"token": token, "timestamp": timestamp};
  }

  @override
  String toString() {
    return 'DataSignature{token: $token, timestamp: $timestamp}';
  }
}

List<DataSignature> signatureFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<DataSignature>.from(
      data.map((item) => DataSignature.fromJson(item)));
}

String signatureToJson(DataSignature data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
