// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) {
  final jsonData = json.decode(str);
  return UserModel.fromJson(jsonData);
}

String userModelToJson(UserModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

Map<String, dynamic> userToMap(UserModel data) {
  final dyn = data.toJson();
  return dyn;
}

userFromJson(Map<String, dynamic> json) => UserModel.fromJson(json);

class UserModel {
  String email;
  String id;
  String auth_id;
  String name;
  String image;
  String about;

  UserModel({
    this.email,
    this.id,
    this.auth_id,
    this.name,
    this.image,
    this.about,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => new UserModel(
        email: json["email"],
        id: json["id"],
        auth_id: json["auth_id"],
        name: json["name"],
        image: json["image"],
        about: json["about"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "id": id,
        "auth_id": auth_id,
        "name": name,
        "image": image,
        "about": about,
      };
}
