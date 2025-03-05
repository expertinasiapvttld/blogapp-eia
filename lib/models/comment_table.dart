// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

Comment commentFromJson(String str) {
  final jsonData = json.decode(str);
  return Comment.fromJson(jsonData);
}

String commentToJson(Comment data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

Map<String, dynamic> commentTableToMap(Comment data) {
  final dyn = data.toJson();
  return dyn;
}

commentFromMap(Map<String, dynamic> json) => Comment.fromJson(json);

class Comment {
  String userId;
  String name;
  String id;
  String image;
  String comment;
  String blogId;
  String createdAt;

  Comment({
    this.userId,
    this.name,
    this.id,
    this.image,
    this.comment,
    this.blogId,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => new Comment(
        userId: json["userId"],
        name: json["name"],
        id: json["id"],
        image: json["image"],
        comment: json["comment"],
        blogId: json["blogId"],
        createdAt: json["createdAt"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "name": name,
        "id": id,
        "image": image,
        "comment": comment,
        "blogId": blogId,
        "createdAt": createdAt,
      };
}
