import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class Activity {
  final DateTime date;
  final String link;
  final String title;
  final String img;
  final int id;

  const Activity({
    required this.date,
    required this.id,
    required this.title,
    required this.img,
    required this.link,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      date: DateTime.parse(json['date']),
      id: json['id'] as int,
      title: json['title'] as String,
      img: json['img'] as String,
      link: json['link'] as String,
    );
  }
}

class ActivityDetail {
  final int id;
  final DateTime date;
  final String link;
  final String title;
  final String description;
  final String img;
  final int orderNumber;
  final String type;

  const ActivityDetail({
    required this.id,
    required this.date,
    required this.link,
    required this.title,
    required this.description,
    required this.img,
    required this.orderNumber,
    required this.type,
  });

  factory ActivityDetail.fromJson(Map<String, dynamic> json) {
    return ActivityDetail(
      id: json['id'] as int,
      date: DateTime.parse(json['date']),
      link: json['link'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      img: json['img'] as String,
      orderNumber: json['orderNumber'] as int,
      type: json['type'] as String,
    );
  }
}


class _ActivityPageState extends State<ActivityPage> {
  List<Activity> activities = [];
  bool isLoading = true;
  List<ActivityDetail> activityDetails = [];
  bool isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    fetchActivities().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    fetchActivityDetails().then((_) {
      setState(() {
        isLoadingDetails = false;
      });
    });
  }

  Future<void> fetchActivities() async {
    final response = await http.post(
      Uri.parse('https://sucsa.org:8004/api/public/events'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> decoded = json.decode(decodedBody);
      if (decoded['code'] == 0 && decoded['msg'] == 'success') {
        List<dynamic> data = decoded['data'];
        setState(() {
          activities = data.map((json) => Activity.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        print('API responded with error: ${decoded['msg']}');
      }
    } else {
      print('Failed to load activities with status code: ${response.statusCode}');
    }
  }

  Future<void> fetchActivityDetails() async {
    final response = await http.post(
      Uri.parse('https://sucsa.org:8004/api/public/activities'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> decoded = json.decode(decodedBody);
      if (decoded['code'] == 0 && decoded['msg'] == 'success') {
        List<dynamic> data = decoded['data'];
        setState(() {
          activityDetails = data.map((json) => ActivityDetail.fromJson(json)).toList();
        });
      } else {
        print('API responded with error: ${decoded['msg']}');
      }
    } else {
      print('Failed to load activity details with status code: ${response.statusCode}');
    }
  }

  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget activityWidget(Activity activity) {
    return InkWell(
      onTap: () => launchURL(activity.link),
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              activity.img,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title, style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text('${activity.date.toLocal()}', style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading || isLoadingDetails) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: CarouselSlider.builder(
              itemCount: activities.length,
              itemBuilder: (context, index, realIndex) {
                return activityWidget(activities[index]);
              },
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                padEnds: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "往期活动",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(29,32,136,1.0)
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: activityDetails.length,
              separatorBuilder: (context, index) => SizedBox.shrink(),
              itemBuilder: (context, index) {
                final detail = activityDetails[index];
                return Card(
                  elevation: 1.0,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Image.network(detail.img, width: 50, height: 50),
                    title: Text(detail.title, style: TextStyle(fontSize: 16)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: SelectableText(detail.title),
                            content: SingleChildScrollView(
                              child: SelectableText(detail.description),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Close', style: TextStyle(color: Color.fromRGBO(29,32,136,1.0))),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );

                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


}
