import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>> staffLogin(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://cms.sucsa.org:8005/api/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> studentLogin(String studentId, String password) async {
    final response = await http.post(
      Uri.parse('https://sucsa.org:8004/api/app/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'studentId': studentId,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }


  Future<void> saveToken(String token, String authToken) async {
    final url = 'http://cms.sucsa.org:8005/api/user/save_token';
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({'token': token}),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Token saved successfully');
    } else {
      print('Failed to save token. Status code: ${response.statusCode}');
      throw Exception('Failed to save token');
    }
  }

  Future<void> sendNotification(String title, String body, int userId) async {
    final url = 'http://cms.sucsa.org:8005/api/notification/send';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'title': title,
        'body': body,
        'userId': userId.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
      throw Exception('Failed to send notification');
    }
  }

}
