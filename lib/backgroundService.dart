// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// Future<void> fetchDataInBackground() async {
//   final activitiesData = await fetchActivities();
//   final activityDetailsData = await fetchActivityDetails();
//   FlutterBackgroundService().invoke('onDataReceived', {
//     'activities': activitiesData,
//     'activityDetails': activityDetailsData,
//   });
// }
//
// Future<List<dynamic>> fetchActivities() async {
//   final response = await http.post(
//     Uri.parse('https://sucsa.org:8004/api/public/events'),
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//     },
//   );
//
//   if (response.statusCode == 200) {
//     final String decodedBody = utf8.decode(response.bodyBytes);
//     final Map<String, dynamic> decoded = json.decode(decodedBody);
//     if (decoded['code'] == 0 && decoded['msg'] == 'success') {
//       return decoded['data'];
//     } else {
//       print('API responded with error: ${decoded['msg']}');
//     }
//   } else {
//     print('Failed to load activities with status code: ${response.statusCode}');
//   }
//
//   return [];
// }
//
// Future<List<dynamic>> fetchActivityDetails() async {
//   final response = await http.post(
//     Uri.parse('https://sucsa.org:8004/api/public/activities'),
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//     },
//   );
//
//   if (response.statusCode == 200) {
//     final String decodedBody = utf8.decode(response.bodyBytes);
//     final Map<String, dynamic> decoded = json.decode(decodedBody);
//     if (decoded['code'] == 0 && decoded['msg'] == 'success') {
//       return decoded['data'];
//     } else {
//       print('API responded with error: ${decoded['msg']}');
//     }
//   } else {
//     print('Failed to load activity details with status code: ${response.statusCode}');
//   }
//
//   return [];
// }
