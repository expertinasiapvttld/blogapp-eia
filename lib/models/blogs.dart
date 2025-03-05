// To parse this JSON data, do
//
//     final blogs = blogsFromJson(jsonString);

import 'dart:convert';

Blogs blogsFromJson(String str) {
  final jsonData = json.decode(str);
  return Blogs.fromJson(jsonData);
}

String blogsToJson(Blogs data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

Map<String, dynamic> blogsToMap(Blogs data) {
  final dyn = data.toJson();
  return dyn;
}

fromJson(Map<String, dynamic> json) => new Blogs(
      blogger_name: json["blogger_name"],
      userId: json["userId"],
      title: json["title"],
      description: json["description"],
      completed: json["completed"],
      image: json["image"],
      id: json["id"],
      createdAt: json["createdAt"],
      likes: new List<String>.from(json["likes"].map((x) => x)),
      comments: new List<String>.from(json["comments"].map((x) => x)),
      follow: new List<String>.from(json["follow"].map((x) => x)),
    );

class Blogs {
  String blogger_name;
  String userId;
  String title;
  String description;
  bool completed;
  String image;
  String id;
  String createdAt;
  List<String> likes;
  List<String> comments;
  List<String> follow;

  Blogs({
    this.blogger_name,
    this.userId,
    this.title,
    this.description,
    this.completed,
    this.image,
    this.id,
    this.createdAt,
    this.likes,
    this.comments,
    this.follow,
  });

  factory Blogs.fromJson(Map<String, dynamic> json) => new Blogs(
        blogger_name: json["blogger_name"],
        userId: json["userId"],
        title: json["title"],
        description: json["description"],
        completed: json["completed"],
        image: json["image"],
        id: json["id"],
        createdAt: json["createdAt"],
        likes: new List<String>.from(json["likes"].map((x) => x)),
        comments: new List<String>.from(json["comments"].map((x) => x)),
        follow: new List<String>.from(json["follow"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "blogger_name": blogger_name,
        "userId": userId,
        "title": title,
        "description": description,
        "completed": completed,
        "image": image,
        "id": id,
        "createdAt": createdAt,
        "likes": new List<dynamic>.from(likes.map((x) => x)),
        "comments": new List<dynamic>.from(comments.map((x) => x)),
        "follow": new List<dynamic>.from(follow.map((x) => x)),
      };
}
