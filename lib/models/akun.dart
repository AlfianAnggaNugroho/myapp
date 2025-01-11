import 'package:cloud_firestore/cloud_firestore.dart';

class Akun {
  String email;
  String password;

  Akun({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory Akun.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> json) {
    return Akun(email: json['email'], password: json['password']);
  }
}
