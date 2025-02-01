// ignore_for_file: file_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

AuthenticationModel authenticationFromJson(String str) =>
    AuthenticationModel.fromJson(json.decode(str));

String authenticationToJson(AuthenticationModel data) =>
    json.encode(data.toJson());

class AuthenticationModel {
  String? id;
  String name;
  String email;
  String? imageUrl;
  String password;

  AuthenticationModel({
    this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.password,
  });

  factory AuthenticationModel.fromJson(DocumentSnapshot json) =>
      AuthenticationModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        imageUrl: json["imageUrl"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "imageUrl": imageUrl,
        "password": password,
      };
}
