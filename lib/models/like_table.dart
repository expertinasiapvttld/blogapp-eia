// To parse this JSON data, do
//
//     final likeTable = likeTableFromJson(jsonString);

import 'dart:convert';

LikeTable likeTableFromJson(String str) {
  final jsonData = json.decode(str);
  return LikeTable.fromJson(jsonData);
}

String likeTableToJson(LikeTable data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

Map<String, dynamic> likeTableToMap(LikeTable data) {
  final dyn = data.toJson();
  return dyn;
}

likeFromMap(Map<String, dynamic> json) => LikeTable.fromJson(json);

class LikeTable {
  String userId;
  String name;
  String id;
  String blogId;
  String image;
  String createdAt;

  LikeTable({
    this.userId,
    this.name,
    this.id,
    this.blogId,
    this.image,
    this.createdAt,
  });

  factory LikeTable.fromJson(Map<String, dynamic> json) => new LikeTable(
        userId: json["userId"],
        name: json["name"],
        id: json["id"],
        blogId: json["blogId"],
        image: json["image"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "id": id,
        "blogId": blogId,
        "image": image,
        "createdAt": createdAt,
      };
}
