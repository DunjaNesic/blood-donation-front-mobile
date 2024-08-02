import 'dart:convert';

class User{
  int userID;
  String accessToken;
  String refreshToken;

  User({required this.userID, required this.accessToken, required this.refreshToken});

  factory User.fromReqBody(String body) {
    Map<String, dynamic> json = jsonDecode(body);

    return User(
      userID: json['userID'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );

  }
  void printAttributes() {
    print("userID: ${this.userID}\n");
    print("email: ${this.accessToken}\n");
    print("pass: ${this.refreshToken}\n");
  }
}

