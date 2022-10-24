import 'dart:convert';

class DataLogin {
  String email;
  String password;

  DataLogin({required this.email, required this.password});

  factory DataLogin.fromJson(Map<String, dynamic> map) {
    return DataLogin(email: map["email"], password: map["password"]);
  }

  Map<String, dynamic> toJson() {
    return {"email": email, "password": password};
  }

  @override
  String toString() {
    return "{email: $email, password: $password}";
  }
}

List<DataLogin> profileFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<DataLogin>.from(data.map((item) => DataLogin.fromJson(item)));
}

String profileToJson(DataLogin data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
