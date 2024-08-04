import 'package:blood_donation/common/api_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthAPI extends BaseAPI {
  Future<http.Response> register(String jmbg, String donorFullName, String email,
      String password, String confirmPassword, int sex, int bloodType, bool isActive, int placeID) async {
    var body = jsonEncode({
      "jmbg": jmbg,
      "donorFullName": donorFullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "sex": sex,
      "bloodType": bloodType,
      "isActive": isActive,
      "placeID": placeID
    });

    http.Response response =
    await http.post(Uri.parse(super.registerPath), headers: super.headers, body: body);
    return response;
  }

  Future<http.Response> login(String email, String password) async {
    var body = jsonEncode({'email': email, 'password': password});

    http.Response response =
    await http.post(Uri.parse(super.authPath), headers: super.headers, body: body);

    return response;
  }

  Future<http.Response> logout(int id, String token) async {
    var body = jsonEncode({'id': id, 'token': token});

    http.Response response = await http.post(Uri.parse(super.authPath),
        headers: super.headers, body: body);

    return response;
  }
}
